"""Rende le fonti del ciclo in pagine HTML 1:1, con la navigazione.

Una pagina per ogni `.md` del perimetro (i register `goal.md`, `world.md` e
`autonomy.md`, e le sei collezioni), allo stesso path del repo con `.html`: `o1/plan.md` diventa
`view/o1/plan.html`. «1:1» è fedeltà al contenuto e alla struttura della
fonte (`kb/view.md`): l'intero corpo passa da Pandoc, il frontmatter si rende
in testa. Un link a un'altra fonte del perimetro diventa il link alla sua
pagina; un link a ciò che non si rende (nodi, README, script) diventa la sua
etichetta, così `view/` resta chiusa su se stessa. Le immagini citate si
copiano accanto alla pagina, allo stesso path relativo.
"""

from __future__ import annotations

import fnmatch
import html
import posixpath
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlsplit, urlunsplit

import project
from sources import (
    PlanRow,
    goal_anchor,
    goal_heading_key,
    goal_keys,
    is_external,
    label,
    pandoc_ast,
    pandoc_render,
    split_frontmatter,
)

# `autonomy.md` è un register senza polo: la home lo collega dalle proposte,
# non come stadio del ciclo.
REGISTERS = ["goal.md", "world.md", "autonomy.md"]

# Le collezioni nell'ordine della home, ciascuna col proprio indice: il nome
# dell'indice è canone, uguale in ogni repo (`kb/project-structure.md`).
INDEXES = {
    "o1": "plan.md",
    "o2": "tasks.md",
    "o3": "prescriptions.md",
    "i3": "verdicts.md",
    "i2": "interpretations.md",
    "i1": "perceptions.md",
}

IMAGE = re.compile(r"\.(png|jpe?g|gif|svg|webp)$", re.IGNORECASE)


@dataclass(frozen=True)
class Page:
    source: str  # path della fonte, relativo alla root: «o2/tasks.md»
    title: str

    @property
    def target(self) -> str:
        return self.source.removesuffix(".md") + ".html"

    @property
    def collection(self) -> str | None:
        head = self.source.split("/", 1)[0]
        return head if head in INDEXES else None


def _excluded(relative: str) -> bool:
    return any(fnmatch.fnmatch(relative, pattern) for pattern in project.ESCLUSE)


def perimeter(root: Path) -> list[str]:
    """Le fonti rese: register e collezioni, tracciate o non ignorate da git.

    Si chiede a git, non al disco, perché ciò che `.gitignore` tiene fuori
    dal repo (dati locali, cache) non deve entrare in una cartella che si
    versiona e si serve. I symlink non si seguono: puntano fuori dal
    checkout. `ESCLUSE` in `project.py` toglie ciò che il repo non vuole
    esporre.

    Le fonti esportate da un commit per la pubblicazione (`publish.py`) non
    hanno `.git`: lì ogni file è tracciato per costruzione e si legge il disco.
    """
    sources = set()
    for relative in _listed(root):
        path = root / relative
        if not relative.endswith(".md") or not path.is_file() or _excluded(relative):
            continue
        if any((root / part).is_symlink() for part in _prefixes(relative)):
            continue
        sources.add(relative)
    for collection, index in INDEXES.items():
        if f"{collection}/{index}" not in sources:
            raise SystemExit(f"{collection}/{index}: indice della collezione assente o escluso")
    return sorted(sources)


def _listed(root: Path) -> list[str]:
    if not (root / ".git").exists():
        found = [name for name in REGISTERS if (root / name).exists()]
        for collection in INDEXES:
            found += [
                path.relative_to(root).as_posix()
                for path in (root / collection).rglob("*")
                if path.is_file() or path.is_symlink()
            ]
        return found
    listed = subprocess.run(
        [
            "git",
            "ls-files",
            "-z",
            "--cached",
            "--others",
            "--exclude-standard",
            "--",
            *REGISTERS,
            *INDEXES,
        ],
        cwd=root,
        capture_output=True,
        check=True,
    ).stdout.decode("utf-8")
    return list(filter(None, listed.split("\0")))


def _prefixes(relative: str) -> list[str]:
    parts = relative.split("/")
    return ["/".join(parts[: index + 1]) for index in range(len(parts))]


def title_of(root: Path, relative: str) -> str:
    _, body = split_frontmatter((root / relative).read_text(encoding="utf-8"))
    for line in body.splitlines():
        if line.startswith("# "):
            return re.sub(r"`([^`]+)`", r"\1", line[2:].strip())
    return Path(relative).stem


def sequence(root: Path, collection: str, pages: dict[str, Page]) -> list[Page]:
    """Le voci di una collezione nell'ordine del suo indice, poi le altre.

    L'indice è la sequenza curata: i fili nell'ordine di `verdicts.md`, i task
    in quello di `tasks.md`. Un file che l'indice non cita resta raggiungibile,
    in coda, invece di sparire dalla navigazione.
    """
    index = f"{collection}/{INDEXES[collection]}"
    ordered: list[Page] = []
    text = (root / index).read_text(encoding="utf-8")
    for match in re.finditer(r"\]\(([^)\s]+\.md)(?:#[^)]*)?\)", text):
        relative = posixpath.normpath(posixpath.join(collection, match.group(1)))
        page = pages.get(relative)
        if page and page.source != index and page not in ordered and page.collection == collection:
            ordered.append(page)
    rest = sorted(
        (p for p in pages.values() if p.collection == collection and p.source != index),
        key=lambda p: p.source,
    )
    return ordered + [page for page in rest if page not in ordered]


# --- Link e immagini -----------------------------------------------------------


def _stringify(inlines: list) -> str:
    out: list[str] = []
    for node in inlines:
        kind = node.get("t")
        if kind == "Str":
            out.append(node["c"])
        elif kind in {"Space", "SoftBreak", "LineBreak"}:
            out.append(" ")
        elif kind == "Code":
            out.append(node["c"][1])
        elif kind in {"Emph", "Strong", "Strikeout", "Underline", "SmallCaps"}:
            out.append(_stringify(node["c"]))
        elif kind in {"Link", "Span", "Quoted"}:
            out.append(_stringify(node["c"][-2] if kind == "Link" else node["c"][-1]))
    return "".join(out)


class Rewriter:
    """Chiude l'AST di una pagina dentro `view/`, ricalcando i path del repo."""

    def __init__(self, root: Path, source: str, rendered: set[str], images: dict[str, Path]):
        self.root = root
        self.source = source
        self.base = posixpath.dirname(source)
        self.rendered = rendered
        self.images = images

    def resolve(self, target: str) -> tuple[str, str] | None:
        """Il path relativo alla root e il frammento, se il target resta nel repo."""
        parts = urlsplit(target)
        if not parts.path:
            return None
        normal = posixpath.normpath(posixpath.join(self.base, parts.path))
        if normal.startswith("../") or normal == ".." or parts.path.startswith("/"):
            return ("", "")
        return normal, parts.fragment

    def link(self, target: str) -> str | None:
        if is_external(target):
            return target
        resolved = self.resolve(target)
        if resolved is None or not resolved[0]:
            return None
        relative, fragment = resolved
        if (self.root / relative).is_dir():
            collection = relative.rstrip("/")
            relative = f"{collection}/{INDEXES[collection]}" if collection in INDEXES else ""
        if relative not in self.rendered:
            return None
        href = posixpath.relpath(relative.removesuffix(".md") + ".html", self.base or ".")
        return urlunsplit(("", "", href, "", fragment))

    def image(self, target: str) -> str:
        if is_external(target):
            return target
        resolved = self.resolve(target)
        relative = resolved[0] if resolved else ""
        path = self.root / relative
        if not relative or not IMAGE.search(relative) or not path.is_file():
            raise SystemExit(f"{self.source}: immagine fuori dal repo o assente — «{target}»")
        if _excluded(relative):
            raise SystemExit(f"{self.source}: immagine esclusa da project.py — «{target}»")
        self.images[relative] = path
        return posixpath.relpath(relative, self.base or ".")

    def walk(self, value: object) -> object:
        if isinstance(value, list):
            out: list[object] = []
            for child in value:
                if isinstance(child, dict) and child.get("t") == "Link":
                    href = self.link(child["c"][-1][0])
                    if href is None:
                        out.extend(self.walk(child["c"][1]))
                        continue
                    child = {**child, "c": [*child["c"][:-1], [href, child["c"][-1][1]]]}
                    child["c"][1] = self.walk(child["c"][1])
                    out.append(child)
                    continue
                out.append(self.walk(child))
            return out
        if not isinstance(value, dict):
            return value
        if value.get("t") == "Image":
            target = value["c"][-1]
            return {**value, "c": [*value["c"][:-1], [self.image(target[0]), target[1]]]}
        return {key: self.walk(child) for key, child in value.items()}


# --- Arricchimenti dei contratti --------------------------------------------------


def _anchor_goals(blocks: list) -> None:
    """In `goal.md` ogni obiettivo riceve l'ancora stabile `ob-<chiave>`."""
    for block in blocks:
        if block.get("t") != "Header":
            continue
        key = goal_heading_key(_stringify(block["c"][2]))
        if key:
            block["c"][1][0] = goal_anchor(key)


def _plain(text: str) -> list:
    return [{"t": "Plain", "c": [{"t": "Str", "c": text}]}]


def _goal_cell(keys: str, base: str) -> list:
    inlines: list = []
    for index, key in enumerate(part.strip() for part in keys.split(",")):
        if index:
            inlines += [{"t": "Str", "c": ","}, {"t": "Space"}]
        href = posixpath.relpath("goal.md", base) + "#" + goal_anchor(key)
        inlines.append({"t": "Link", "c": [["", [], []], [{"t": "Str", "c": key}], [href, ""]]})
    return [{"t": "Plain", "c": inlines}]


def _link_plan(blocks: list, rows: list[PlanRow]) -> None:
    """La tabella del plan collega `Ob.` a `goal.html` e il task alla sua specifica.

    I legami sono quelli che il contratto plan × o2 ha già verificato: la
    pagina li rende percorribili, non li ricostruisce. Puntano alle fonti
    `.md`, come un link scritto a mano: la riscrittura verso `.html` è una
    sola, quella del `Rewriter`.
    """
    table = next((block for block in blocks if block.get("t") == "Table"), None)
    if table is None or not rows:
        return
    head_rows = table["c"][3][1]
    if not head_rows:
        return
    headers = [_stringify(cell[4][0]["c"]) if cell[4] else "" for cell in head_rows[0][1]]
    column = {name.strip(): index for index, name in enumerate(headers)}
    body_rows = [row for body in table["c"][4] for row in body[3]]
    for row, plan_row in zip(body_rows, rows):
        cells = row[1]
        if "Ob." in column and plan_row.obiettivo:
            cells[column["Ob."]][4] = _goal_cell(plan_row.obiettivo, "o1")
        if "Task" in column and plan_row.source:
            cell = cells[column["Task"]]
            content = cell[4][0]["c"] if cell[4] else []
            if not any(node.get("t") == "Link" for node in content):
                href = posixpath.relpath(plan_row.source, "o1")
                cell[4] = [
                    {"t": "Plain", "c": [{"t": "Link", "c": [["", [], []], content, [href, ""]]}]}
                ]


def _wrap_tables(blocks: list) -> list:
    """Ogni tabella scorre da sola: su schermo stretto non dilata la pagina."""
    out = []
    for block in blocks:
        if block.get("t") == "Table":
            block = {"t": "Div", "c": [["", ["table-scroll"], []], [block]]}
        out.append(block)
    return out


# --- Pagina -----------------------------------------------------------------------


def _meta_html(meta: dict[str, str], base: str, keys: set[str]) -> str:
    if not meta:
        return ""
    items = []
    for key, value in meta.items():
        shown = html.escape(value)
        if key == "obiettivo" and value:
            links = []
            for part in (p.strip() for p in value.split(",")):
                if part in keys:
                    href = posixpath.relpath("goal.html", base or ".") + "#" + goal_anchor(part)
                    links.append(f'<a href="{href}">{html.escape(part)}</a>')
                else:
                    links.append(html.escape(part))
            shown = ", ".join(links)
        items.append(f"<div><dt>{html.escape(key)}</dt><dd>{shown}</dd></div>")
    return f'<dl class="page-meta">{"".join(items)}</dl>'


def _nav_html(page: Page, pages: dict[str, Page], root: Path) -> str:
    base = posixpath.dirname(page.source) or "."

    def rel(target: str) -> str:
        return posixpath.relpath(target, base)

    parts = [f'<a class="nav-home" href="{rel("index.html")}">{html.escape(project.SIGLA)}</a>']
    collection = page.collection
    if collection:
        index = pages[f"{collection}/{INDEXES[collection]}"]
        current = ' aria-current="page"' if page is index else ""
        parts.append(
            f'<a class="nav-index" href="{rel(index.target)}"{current}>'
            f'<span class="nav-key">{collection}</span> {html.escape(index.title)}</a>'
        )
        items = sequence(root, collection, pages)
        if items:
            dots = []
            for item in items:
                current = ' aria-current="page"' if item is page else ""
                dots.append(
                    f'<li><a href="{rel(item.target)}" title="{html.escape(item.title, quote=True)}"'
                    f'{current}><span class="dot" aria-hidden="true"></span>'
                    f'<span class="nav-label">{html.escape(item.title)}</span></a></li>'
                )
            parts.append(f'<ol class="nav-thread">{"".join(dots)}</ol>')
    else:
        for register in REGISTERS:
            other = pages.get(register)
            if other:
                current = ' aria-current="page"' if other is page else ""
                parts.append(
                    f'<a class="nav-index" href="{rel(other.target)}"{current}>'
                    f"{html.escape(other.title)}</a>"
                )
    return f'<nav class="site-nav" aria-label="{label("nav")}">{"".join(parts)}</nav>'


def render_page(
    root: Path,
    page: Page,
    pages: dict[str, Page],
    images: dict[str, Path],
    rows: list[PlanRow],
) -> str:
    meta, body = split_frontmatter((root / page.source).read_text(encoding="utf-8"))
    document = pandoc_ast(body)
    blocks = document["blocks"]
    if page.source == "goal.md":
        _anchor_goals(blocks)
    if page.source == "o1/plan.md":
        _link_plan(blocks, rows)
    rewriter = Rewriter(root, page.source, set(pages), images)
    document["blocks"] = _wrap_tables(rewriter.walk(blocks))
    content = pandoc_render(document, ["--to=html5", "--wrap=none"]).rstrip()
    base = posixpath.dirname(page.source)
    assets = posixpath.relpath("assets", base or ".")
    lang = "it" if project.LINGUA == "it" else "en"
    return f"""<!doctype html>
<html lang="{lang}">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{html.escape(project.SIGLA)} · {html.escape(page.title)}</title>
    <link rel="stylesheet" href="{assets}/page.css" />
    <link rel="stylesheet" href="{assets}/theme.css" />
  </head>
  <body>
    {_nav_html(page, pages, root)}
    <main class="page-body">
      <p class="page-source">{html.escape(page.source)}</p>
      {_meta_html(meta, base, goal_keys(root))}
      {content}
    </main>
  </body>
</html>
"""


def render_all(root: Path, rows: list[PlanRow]) -> tuple[dict[str, str], dict[str, Path]]:
    """Tutte le pagine del perimetro (path in `view/` → HTML) e le immagini citate."""
    pages = {relative: Page(relative, title_of(root, relative)) for relative in perimeter(root)}
    images: dict[str, Path] = {}
    outputs = {page.target: render_page(root, page, pages, images, rows) for page in pages.values()}
    return outputs, images
