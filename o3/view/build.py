"""Rigenera l'intera `view/`: pagine 1:1, deck, home e asset.

È l'unico entrypoint di build, con lo stesso path in ogni repo
(`python3 o3/view/build.py`, su Windows `py o3\\view\\build.py`). È Python e
non bash perché deve girare anche sugli host Windows. `view/` è tutta
generata e ignorata da git: ciò che la build non produce più si rimuove, così una fonte
cancellata non lascia una pagina orfana. Due build consecutive producono lo
stesso output; alla fine il presidio verifica che nessun URL emesso esca da
`view/` (`kb/view.md`).

La build scrive sempre in una cartella temporanea e copia in `view/` solo a
esito riuscito: un errore, anche tardivo, lascia intatta la vista precedente.

- senza argomenti: rende il working tree in `view/`;
- `--check`: verifica contratti e resa senza toccare `view/`;
- `--out DIR`: rende in una cartella nuova (lo usa la pubblicazione);
- `--publish DIR`: pubblica da un commit pulito (`--rev`, default `HEAD`)
  nella cartella di pubblicazione dell'host, conservando l'ultima vista
  buona (`publish.py`).
"""

from __future__ import annotations

import argparse
import importlib
import inspect
import json
import platform
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import project
from build_pages import render_all
from build_system_image import render as render_home
from sources import (
    check_closed,
    check_plan_contract,
    check_verdict_contract,
    label,
    parse_plan,
    check_deck_exit,
    reveal_page,
)

ROOT = Path(__file__).resolve().parents[2]
VIEW = ROOT / "view"
ASSETS = VIEW / "assets"
CANONICAL_ASSETS = Path(__file__).resolve().parent / "assets"
PRESENTATION = ROOT / "presentation"


def require(tool: str) -> str:
    path = shutil.which(tool)
    if not path:
        raise SystemExit(f"build: «{tool}» non trovato nel PATH")
    return path


def version(tool: str) -> str:
    first = subprocess.run(
        [tool, "--version"], text=True, encoding="utf-8", capture_output=True, check=True
    ).stdout.splitlines()
    line = first[0].strip() if first else "?"
    name = Path(tool).name
    return line if line.lower().startswith(name) else f"{name} {line}"


def revealjs_url() -> str:
    """La versione di reveal.js la detta il template di pandoc, non noi.

    Fino alla 3.11 i percorsi dei plugin sono quelli della serie 5
    (plugin/notes/notes.js), dalla 3.12 quelli della 6 (dist/plugin/notes.js).
    Un URL che non corrisponde lascia le slide bianche senza errori.
    """
    first = subprocess.run(
        ["pandoc", "--version"], text=True, encoding="utf-8", capture_output=True, check=True
    ).stdout.splitlines()[0]
    match = re.match(r"\S+\s+(\d+)\.(\d+)", first)
    if not match:
        raise SystemExit(f"build: versione di pandoc non riconosciuta: «{first}»")
    major, minor = int(match.group(1)), int(match.group(2))
    if (major, minor) >= (3, 12):
        return "https://cdn.jsdelivr.net/npm/reveal.js@6.0.2"
    return "https://cdn.jsdelivr.net/npm/reveal.js@5.1.0"


def write(path: Path, content: str | bytes) -> None:
    """Scrive solo se cambia: la rigenerazione resta un gesto senza rumore.

    I testi si scrivono in byte UTF-8 con i loro `\n`: su Windows la
    scrittura in modo testo li tradurrebbe in CRLF.
    """
    data = content.encode("utf-8") if isinstance(content, str) else content
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists() or path.read_bytes() != data:
        path.write_bytes(data)


def theme_css() -> str:
    if not re.fullmatch(r"#[0-9a-fA-F]{6}", project.ACCENTO):
        raise SystemExit(f"project.py: ACCENTO «{project.ACCENTO}» non è un colore #rrggbb")
    return (
        "/* Generato da o3/view/build.py da project.py: non modificare. */\n"
        f":root {{\n  --accent: {project.ACCENTO};\n  --accent-ink: {project.ACCENTO};\n}}\n"
    )


def plates(deck: Path) -> dict[str, bytes]:
    """Le tavole hanno la fonte accanto al deck e si citano come `assets/<nome>`."""
    text = deck.read_text(encoding="utf-8")
    found: dict[str, bytes] = {}
    for name in sorted(set(re.findall(r"assets/([\w.-]+\.(?:png|jpe?g|svg|webp))", text))):
        source = deck.parent / name
        if source.exists():
            found[f"assets/{name}"] = source.read_bytes()
    return found


def deck_page(reveal_url: str, out: Path) -> str | None:
    """Il deck: un Markdown in `DECK`, un builder di dominio in `DECK_BUILDER`, o nessuno.

    Il builder di dominio vive accanto ai builder canonici ed espone
    `render(root, reveal_url, folder) -> str`, la pagina completa: `folder` è
    la cartella in cui la build sta rendendo, l'unica contro cui chiudere i
    link (non `root / "view"`, che durante una build non è l'output). Il
    presidio finale vale anche per questa pagina.
    """
    if project.DECK and project.DECK_BUILDER:
        raise SystemExit("project.py: DECK e DECK_BUILDER sono alternativi, dichiarane uno")
    if project.DECK_BUILDER:
        builder = importlib.import_module(project.DECK_BUILDER).render
        if len(inspect.signature(builder).parameters) < 3:
            raise SystemExit(
                f"{project.DECK_BUILDER}.render deve accettare la cartella di uscita: "
                "render(root, reveal_url, folder) (cfr. la prescrizione viste-fuori-da-git)"
            )
        return builder(ROOT, reveal_url, out)
    if project.DECK:
        deck = ROOT / project.DECK
        return reveal_page(
            deck.read_text(encoding="utf-8"), project.DECK, label("presentation"), reveal_url, out
        )
    return None


def render(out: Path, commit: str | None = None) -> None:
    """Rende tutte le viste in `out`, cartella vuota o nuova.

    Con `commit` la home dichiara la revisione costruita e il toolchain, e
    `provenance.json` li registra: è la vista pubblicata da fonti pulite.
    """
    require("pandoc")
    prettier = require("prettier")
    reveal_url = revealjs_url()

    # I contratti fra le fonti si verificano prima di rendere: una vista
    # plausibile su fonti che si contraddicono è il difetto da evitare.
    rows = parse_plan(ROOT)
    check_plan_contract(ROOT, rows)
    check_verdict_contract(ROOT)

    binaries: dict[str, bytes] = {"assets/theme.css": theme_css().encode("utf-8")}
    for css in sorted(CANONICAL_ASSETS.glob("*.css")):
        binaries[f"assets/{css.name}"] = css.read_bytes()
    for name in project.CSS_LOCALI:
        binaries[f"assets/{name}"] = (PRESENTATION / name).read_bytes()
    if project.DECK:
        binaries |= plates(ROOT / project.DECK)

    pages, images = render_all(ROOT, rows)
    for relative, path in images.items():
        binaries[relative] = path.read_bytes()

    # Le tavole e le immagini devono esistere prima di rendere il deck: il suo
    # presidio verifica che stiano nella cartella.
    for relative, data in binaries.items():
        write(out / relative, data)

    provenance = None
    if commit:
        provenance = {
            "commit": commit,
            "pandoc": version("pandoc"),
            "prettier": version(prettier),
            "python": platform.python_version(),
        }
        write(out / "provenance.json", json.dumps(provenance, indent=2) + "\n")

    texts = dict(pages)
    deck = deck_page(reveal_url, out)
    if deck is not None:
        check_deck_exit(deck)
    if deck is not None:
        texts["presentation.html"] = deck
    texts["index.html"] = render_home(ROOT, deck is not None, provenance)

    for relative, content in texts.items():
        write(out / relative, content)

    subprocess.run(
        [prettier, "--log-level=warn", "--write", *(str(out / name) for name in texts)],
        check=True,
    )
    check_closed(out)


def sync(staged: Path, target: Path) -> None:
    """Porta in `target` l'esito riuscito: scrive ciò che cambia, pota il resto."""
    expected = set()
    for path in sorted(staged.rglob("*")):
        if path.is_file():
            relative = path.relative_to(staged)
            expected.add(target / relative)
            write(target / relative, path.read_bytes())
    if not target.exists():
        return
    for path in sorted(target.rglob("*"), reverse=True):
        if path.is_file() and path not in expected:
            path.unlink()
        elif path.is_dir() and not any(path.iterdir()):
            path.rmdir()


def main() -> None:
    parser = argparse.ArgumentParser(description="Rigenera le viste in view/")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="verifica senza toccare view/")
    mode.add_argument("--out", type=Path, help="rende in una cartella nuova")
    mode.add_argument("--publish", type=Path, metavar="DIR", help="pubblica da un commit pulito")
    parser.add_argument("--rev", default="HEAD", help="revisione da pubblicare (con --publish)")
    parser.add_argument("--commit", help=argparse.SUPPRESS)
    args = parser.parse_args()

    if args.publish:
        from publish import publish

        sys.exit(publish(ROOT, args.publish.resolve(), args.rev))
    try:
        if args.out:
            if args.out.exists():
                raise SystemExit(f"build: {args.out} esiste già, serve una cartella nuova")
            render(args.out.resolve(), args.commit)
            return
        with tempfile.TemporaryDirectory(prefix="view-") as tmp:
            staged = Path(tmp) / "view"
            render(staged)
            if not args.check:
                sync(staged, VIEW)
    except subprocess.CalledProcessError as error:
        tool = Path(str(error.cmd[0])).name
        raise SystemExit(
            f"build: {tool} è uscito con codice {error.returncode}; nessuna vista sostituita"
        ) from None


if __name__ == "__main__":
    main()
