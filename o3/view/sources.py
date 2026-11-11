"""Parsing condiviso per viste generate e system image."""

from __future__ import annotations

import html
import json
import posixpath
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlsplit

import project

# Le poche etichette che la build scrive di suo, nelle due lingue ammesse: i
# titoli delle pagine si leggono dalle fonti, la sigla la mette `project.py`.
LABELS = {
    "en": {
        "presentation": "Presentation",
        "register": "Full register",
        "nav": "Navigation",
        "preview": "Preview of the working tree, not published",
        "pending": "To decide",
        "no-pending": "No proposal waiting for a decision.",
        "delegation": "Delegation criteria",
        "views": "views",
    },
    "it": {
        "presentation": "Presentazione",
        "register": "Register completo",
        "nav": "Navigazione",
        "preview": "Anteprima del working tree, non pubblicata",
        "pending": "Da decidere",
        "no-pending": "Nessuna proposta in attesa di decisione.",
        "delegation": "Criteri della delega",
        "views": "viste",
    },
}


def label(kind: str) -> str:
    """Un'etichetta della build nella lingua del repo."""
    if project.LINGUA not in LABELS:
        raise SystemExit(f"project.py: LINGUA «{project.LINGUA}» non ammessa ({', '.join(LABELS)})")
    return LABELS[project.LINGUA][kind]


@dataclass(frozen=True)
class PlanRow:
    position: str
    task: str
    dependency: str
    source: str | None
    ciclo: str | None = None
    obiettivo: str | None = None


@dataclass(frozen=True)
class TaskDetail:
    path: Path
    title: str
    ciclo: str
    sintesi: str
    # La questione di una proposta in attesa del custode; vuota se non ce n'è
    # (`autonomy.md`, «Decisioni riservate»).
    decidere: str = ""


def split_frontmatter(text: str) -> tuple[dict[str, str], str]:
    if not text.startswith("---\n"):
        return {}, text
    parts = text.split("---\n", 2)
    if len(parts) < 3:
        return {}, text
    meta: dict[str, str] = {}
    for line in parts[1].splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        meta[key.strip()] = value.strip().strip('"')
    return meta, parts[2].lstrip()


def first_h1(markdown: str, fallback: str) -> str:
    for line in markdown.splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return fallback


def _norm(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", " ", value.lower()).strip()


def _detail_source(detail_links: dict[str, str], task: str) -> str | None:
    task_norm = _norm(task)
    if task in detail_links:
        return detail_links[task]
    for title, source in detail_links.items():
        title_norm = _norm(title)
        if title_norm.startswith(task_norm) or task_norm.startswith(title_norm):
            return source
    return None


_INDEX_ENTRY = re.compile(r"^- \[[^\]]+\]\(([^)]+\.md)\)", re.MULTILINE)


def o2_index(root: Path) -> list[str]:
    """I file `o2/` indicizzati da `o2/tasks.md`, come path relativi alla root.

    `o2/tasks.md` è l'**unico** indice dei dettagli (cfr. `kb/tasks.md`): è la
    chiave con cui una riga del plan risolve al proprio file. Le voci che
    puntano fuori da `o2/` (rimandi ai nodi nel preambolo) non sono voci
    d'indice.
    """
    index = root / "o2" / "tasks.md"
    if not index.exists():
        return []
    entries: list[str] = []
    for match in _INDEX_ENTRY.finditer(index.read_text(encoding="utf-8")):
        href = match.group(1).removeprefix("../")
        if "/" in href.removeprefix("o2/"):
            continue
        relative = href if href.startswith("o2/") else f"o2/{href}"
        if relative not in entries:
            entries.append(relative)
    return entries


def _index_titles(root: Path) -> dict[str, str]:
    titles: dict[str, str] = {}
    for relative in o2_index(root):
        if (root / relative).exists():
            titles[parse_task(root, relative).title] = relative
    return titles


# La sezione delle ricorrenze ha una tabella propria (`kb/plan.md`, «Ricorrenze»).
_RICORRENZE = "## Ricorrenze"
_RICORRENZE_COLONNE = ["Prossima", "Cadenza", "Esecutore", "Ob.", "Ricorrenza"]
_CADENZE = {
    "quotidiano",
    "settimanale",
    "mensile",
    "trimestrale",
    "semestrale",
    "annuale",
    "biennale",
}
_ESECUTORI = {"scheduler", "giro", "sessione", "task"}
_PROSSIMA = re.compile(r"(?:entro )?\d{4}-\d{2}(?:-\d{2})?")
_LINK_PROCEDURA = re.compile(r"\[[^\]]+\]\(([^)#]+)(?:#[^)]*)?\)")


def parse_plan(root: Path) -> list[PlanRow]:
    plan = root / "o1" / "plan.md"
    text = plan.read_text(encoding="utf-8")
    # L'indice unico `o2/tasks.md` è la chiave canonica; i bullet `- [x](o2/…)`
    # nel plan sono la forma precedente, ancora in uso negli adottanti.
    detail_links = _index_titles(root)
    detail_links.update(
        {
            match.group(1).strip(): match.group(2).removeprefix("../")
            for match in re.finditer(r"- \[([^\]]+)\]\(((?:\.\./)?o2/[^)]+\.md)\)", text)
        }
    )
    rows: list[PlanRow] = []
    position = 0
    section = ""
    for line in text.splitlines():
        if line.startswith("## "):
            section = line.strip()
        if not line.startswith("|") or section == _RICORRENZE:
            continue
        cells = [
            cell.strip().replace("<<PIPE>>", "|")
            for cell in line.replace(r"\|", "<<PIPE>>").strip().strip("|").split("|")
        ]
        if cells[0] in {"#", "Task", "Ciclo"} or set(cells[0]) == {"-"}:
            continue
        if len(cells) not in {2, 3, 4}:
            # Una riga di tabella che il parser non sa leggere non si salta in
            # silenzio: sarebbe un task invisibile alla vista mentre il plan lo
            # dichiara (`kb/view.md`, «Derivata implica verificata»).
            raise SystemExit(
                f"o1/plan.md: riga di tabella con {len(cells)} colonne, "
                f"forma non riconosciuta — «{line.strip()}»"
            )
        ciclo: str | None = None
        obiettivo: str | None = None
        if len(cells) == 4:
            # Forma canonica: Ciclo · Ob. · Task · Dip.
            position += 1
            position_value, task_cell, dependency = str(position), cells[2], cells[3]
            ciclo, obiettivo = cells[0], cells[1]
        elif len(cells) == 3 and cells[0] in {"dev", "runtime"}:
            # Forma precedente (Ciclo · Task · Dip.), ancora in uso negli adottanti.
            position += 1
            position_value, task_cell, dependency = str(position), cells[1], cells[2]
            ciclo = cells[0]
        elif len(cells) == 3 and cells[1] in {"dev", "runtime"}:
            # Forma precedente (Task · Ciclo · Dip.), ancora in uso negli adottanti.
            position += 1
            position_value, task_cell, dependency = str(position), cells[0], cells[2]
            ciclo = cells[1]
        elif len(cells) == 3:
            position_value, task_cell, dependency = cells
        else:
            position += 1
            position_value, task_cell, dependency = str(position), cells[0], cells[1]
        link = re.search(r"\[([^\]]+)\]\(((?:\.\./)?o2/[^)]+\.md)\)", task_cell)
        task = link.group(1) if link else task_cell
        source = link.group(2).removeprefix("../") if link else _detail_source(detail_links, task)
        rows.append(
            PlanRow(
                position=position_value,
                task=task,
                dependency=dependency,
                source=source,
                ciclo=ciclo,
                obiettivo=obiettivo,
            )
        )
    return rows


def _check_direzione(root: Path) -> list[str]:
    """Verifica la forma della direzione quando il repo l'ha adottata."""
    lines = (root / "o1" / "plan.md").read_text(encoding="utf-8").splitlines()
    headings = [(index, line) for index, line in enumerate(lines) if line.startswith("## ")]
    directions = [index for index, heading in headings if heading == "## Direzione"]
    if not directions:
        return []  # I plan degli adottanti recepiscono il canone localmente.
    if len(directions) != 1:
        return ["o1/plan.md: `## Direzione` deve comparire una sola volta"]
    if not headings or headings[0] != (directions[0], "## Direzione"):
        return ["o1/plan.md: `## Direzione` deve precedere le altre sezioni"]
    end = next((index for index, _ in headings if index > directions[0]), len(lines))
    body = [line.strip() for line in lines[directions[0] + 1 : end] if line.strip()]
    if not body or any(line.startswith(("|", "- ", "* ")) for line in body):
        return ["o1/plan.md: `## Direzione` richiede una breve sintesi in prosa"]
    return []


_GOAL_HEADING = re.compile(r"^#{2,4}\s+((\d+)[.)]\s.*?)\s*$", re.MULTILINE)
_DEV_GOAL_HEADING = re.compile(r"^##\s+(Goal di sviluppo)\s*$", re.MULTILINE)


def goal_anchor(key: str) -> str:
    """L'ancora stabile di un obiettivo in `goal.html`: `ob-1`, `ob-s`.

    Si deriva dalla chiave, non dal titolo: rinominare un obiettivo non rompe
    i link della colonna `Ob.`, e la numerazione è già stabile per contratto
    (`kb/goal.md`).
    """
    return f"ob-{key.lower()}"


def goal_heading_key(title: str) -> str | None:
    """La chiave di un'intestazione di `goal.md`, se è un obiettivo."""
    match = re.match(r"^(\d+)[.)]\s", title)
    if match:
        return match.group(1)
    if title.strip() == "Goal di sviluppo":
        return "S"
    return None


def goal_anchors(root: Path) -> dict[str, str]:
    """Le chiavi che la colonna `Ob.` del plan può assumere, con la loro ancora.

    Il numero dell'obiettivo runtime, più `S` per il Goal di sviluppo: sono le
    chiavi del register, non una lista da tenere in sincronia (`kb/goal.md`).
    """
    goal = root / "goal.md"
    if not goal.exists():
        return {}
    text = goal.read_text(encoding="utf-8")
    anchors = {key: goal_anchor(key) for _, key in _GOAL_HEADING.findall(text)}
    if _DEV_GOAL_HEADING.search(text):
        anchors["S"] = goal_anchor("S")
    return anchors


def goal_titles(root: Path) -> dict[str, str]:
    """Le chiavi del register con il titolo dell'obiettivo, nell'ordine di `goal.md`."""
    goal = root / "goal.md"
    if not goal.exists():
        return {}
    text = goal.read_text(encoding="utf-8")
    titles = {key: re.sub(r"^\d+[.)]\s+", "", title) for title, key in _GOAL_HEADING.findall(text)}
    dev = _DEV_GOAL_HEADING.search(text)
    if dev:
        titles["S"] = dev.group(1)
    return titles


def goal_keys(root: Path) -> set[str]:
    return set(goal_anchors(root))


def _check_obiettivi(root: Path, rows: list[PlanRow]) -> list[str]:
    """La colonna `Ob.` è derivata dal register: si verifica, non si assume.

    La direzione task→obiettivo vive solo qui (`kb/plan.md`): una chiave vuota
    è un task che non serve nessun obiettivo, una chiave che il register non ha
    è una numerazione andata alla deriva. Entrambe rompono, invece di produrre
    una vista che tace.
    """
    declared = {row.obiettivo for row in rows if row.obiettivo is not None}
    if not declared:
        return []
    keys = goal_keys(root)
    if not keys:
        return ["goal.md: nessun obiettivo numerato, ma o1/plan.md dichiara la colonna Ob."]
    errors: list[str] = []
    for row in rows:
        if row.obiettivo is None:
            continue
        if not row.obiettivo:
            errors.append(f"o1/plan.md: «{row.task}» senza obiettivo (colonna Ob. vuota)")
            continue
        unknown = [key for key in row.obiettivo.split(",") if key.strip() not in keys]
        if unknown:
            errors.append(
                f"o1/plan.md: «{row.task}» punta a obiettivi assenti dal register "
                f"({', '.join(key.strip() for key in unknown)})"
            )
    return errors


# La chiosa apre il suo bullet con l'indice, nelle grafie in uso:
# «- `w3` — …», «- w1 — …», «- p1 → …», «- **w1 · Titolo** — …».
_LEGEND_ENTRY = re.compile(r"^\s*[-*]\s+[*`]*([wp]\d+)!?[*`]*\s*[—–:→·-]", re.MULTILINE)
_DEPENDENCY_INDEX = re.compile(r"\b([wp]\d+)!?(?![\w])")


def _check_legenda(root: Path, rows: list[PlanRow]) -> list[str]:
    """Indici `w`/`p` della colonna `Dip.` contro la legenda del plan
    (`kb/plan.md`): una chiosa senza riga è il rimando di un task chiuso
    rimasto nel plan, un indice senza chiosa è un'attesa senza causa."""
    text = (root / "o1" / "plan.md").read_text(encoding="utf-8")
    legend = set(_LEGEND_ENTRY.findall(text))
    used: dict[str, str] = {}
    for row in rows:
        for index in _DEPENDENCY_INDEX.findall(row.dependency):
            used.setdefault(index, row.task)
    errors = [
        f"legenda del plan: {index} senza riga che lo porti in Dip. "
        "(chiosa di un'attesa chiusa o di un task uscito dal plan)"
        for index in sorted(legend - used.keys())
    ]
    errors += [
        f"legenda del plan: {index} in Dip. di «{used[index]}» senza chiosa"
        for index in sorted(used.keys() - legend)
    ]
    return errors


def _righe_ricorrenze(text: str) -> list[list[str]]:
    """Le righe di tabella della sezione `## Ricorrenze`, intestazione compresa."""
    righe: list[list[str]] = []
    section = ""
    for line in text.splitlines():
        if line.startswith("## "):
            section = line.strip()
        if section == _RICORRENZE and line.startswith("|"):
            righe.append([cell.strip() for cell in line.strip().strip("|").split("|")])
    return [riga for riga in righe if set("".join(riga)) - set("-: ")]


def _check_riga_ricorrenza(root: Path, riga: list[str], keys: set[str]) -> list[str]:
    prossima, cadenza, esecutore, obiettivo, ricorrenza = riga
    errors: list[str] = []
    prefix = f"ricorrenze del plan: «{ricorrenza}»"
    if esecutore not in _ESECUTORI:
        errors.append(f"{prefix}: esecutore «{esecutore}» sconosciuto")
    if (prossima == "config") != (esecutore == "scheduler"):
        errors.append(f"{prefix}: `config` e `scheduler` vanno insieme")
    elif prossima != "config" and not _PROSSIMA.fullmatch(prossima):
        errors.append(f"{prefix}: Prossima «{prossima}» non riconosciuta")
    if esecutore == "task" and prossima.startswith("entro "):
        errors.append(f"{prefix}: una riga `task` non porta `entro`")
    if cadenza not in _CADENZE:
        errors.append(f"{prefix}: cadenza «{cadenza}» sconosciuta")
    unknown = [key.strip() for key in obiettivo.split(",") if key.strip() not in keys]
    if not obiettivo or unknown:
        errors.append(f"{prefix}: Ob. «{obiettivo}» vuoto o assente dal register")
    link = _LINK_PROCEDURA.search(ricorrenza)
    if link is None:
        errors.append(f"{prefix}: senza link alla procedura")
    elif not (root / "o1" / link.group(1)).exists():
        errors.append(f"{prefix}: procedura {link.group(1)} inesistente")
    return errors


def _check_ricorrenze(root: Path) -> list[str]:
    """La forma della sezione `## Ricorrenze` (`kb/plan.md`); lo stato delle
    date no: una ricorrenza dovuta è un fatto del giro, non un errore di forma."""
    righe = _righe_ricorrenze((root / "o1" / "plan.md").read_text(encoding="utf-8"))
    if not righe:
        return []
    if righe[0] != _RICORRENZE_COLONNE:
        return [f"ricorrenze del plan: colonne attese {' · '.join(_RICORRENZE_COLONNE)}"]
    keys = goal_keys(root)
    errors: list[str] = []
    for riga in righe[1:]:
        if len(riga) != len(_RICORRENZE_COLONNE):
            errors.append(f"ricorrenze del plan: riga con {len(riga)} colonne — {riga}")
            continue
        errors += _check_riga_ricorrenza(root, riga, keys)
    return errors


def check_plan_contract(root: Path, rows: list[PlanRow]) -> None:
    """Legge plan e `o2/` come un contratto: rompe invece di degradare.

    Una riga del plan **può** non avere dettaglio (`kb/tasks.md`: il file serve
    «quando serve contesto»), ma un file `o2/` scollegato, non indicizzato o in
    contraddizione col plan è una divergenza tra due fonti dello stesso fatto —
    la vista che la ignora invita ad agire su ciò che il plan non dice più
    (`kb/view.md`, «Derivata implica verificata»).
    """
    errors: list[str] = []
    indexed = o2_index(root)
    on_disk = sorted(
        f"o2/{path.name}" for path in (root / "o2").glob("*.md") if path.name != "tasks.md"
    )

    for relative in indexed:
        if not (root / relative).exists():
            errors.append(f"{relative}: voce di o2/tasks.md senza file")
    for relative in on_disk:
        if relative not in indexed:
            errors.append(f"{relative}: file non indicizzato in o2/tasks.md")

    bound: dict[str, list[str]] = {}
    for row in rows:
        if row.source:
            bound.setdefault(row.source, []).append(row.task)
    for relative in on_disk:
        if relative not in bound:
            errors.append(
                f"{relative}: nessuna riga di o1/plan.md risolve a questo file "
                f"(titolo «{parse_task(root, relative).title}»)"
            )
        elif len(bound[relative]) > 1:
            errors.append(
                f"{relative}: risolto da più righe del plan ({', '.join(bound[relative])})"
            )

    for row in rows:
        if not row.source or not row.ciclo:
            continue
        detail_ciclo = parse_task(root, row.source).ciclo
        if detail_ciclo != row.ciclo:
            errors.append(
                f"{row.source}: ciclo divergente — plan «{row.ciclo}», frontmatter «{detail_ciclo}»"
            )

    errors += _check_direzione(root)
    errors += _check_obiettivi(root, rows)
    errors += _check_legenda(root, rows)
    errors += _check_ricorrenze(root)

    if errors:
        raise SystemExit("contratto plan × o2 violato:\n- " + "\n- ".join(errors))


@dataclass(frozen=True)
class Thread:
    name: str
    title: str
    ciclo: str
    obiettivo: str
    body: str


def i3_index(root: Path) -> list[str]:
    """I file di `i3/` nell'ordine curato dell'indice `i3/verdicts.md`."""
    index = root / "i3" / "verdicts.md"
    if not index.exists():
        return []
    names: list[str] = []
    for match in _INDEX_ENTRY.finditer(index.read_text(encoding="utf-8")):
        href = match.group(1)
        if "/" not in href and href != "verdicts.md" and href not in names:
            names.append(href)
    return names


def parse_thread(root: Path, name: str) -> Thread:
    meta, body = split_frontmatter((root / "i3" / name).read_text(encoding="utf-8"))
    title = first_h1(body, name.removesuffix(".md"))
    body = re.sub(r"^# .*\n?", "", body, count=1, flags=re.MULTILINE).strip()
    return Thread(
        name=name,
        title=title,
        ciclo=meta.get("ciclo", ""),
        obiettivo=meta.get("obiettivo", ""),
        body=body,
    )


def check_verdict_contract(root: Path) -> list[Thread]:
    """Legge `i3/` come contratto: indice, file e obiettivi devono coincidere.

    Un filo misura un obiettivo di `goal.md` o non è un filo (`kb/verdict.md`,
    «Che cosa è un filo»): una chiave vuota o assente dal register rompe la
    build, come la colonna `Ob.` del plan. Un file fuori indice o una voce
    senza file sono due fonti dello stesso fatto che divergono.
    """
    errors: list[str] = []
    indexed = i3_index(root)
    on_disk = sorted(path.name for path in (root / "i3").glob("*.md") if path.name != "verdicts.md")
    for name in indexed:
        if name not in on_disk:
            errors.append(f"i3/{name}: voce di i3/verdicts.md senza file")
    for name in on_disk:
        if name not in indexed:
            errors.append(f"i3/{name}: file non indicizzato in i3/verdicts.md")
    keys = goal_keys(root)
    threads: list[Thread] = []
    for name in (name for name in indexed if name in on_disk):
        thread = parse_thread(root, name)
        if thread.ciclo not in {"dev", "runtime"}:
            errors.append(f"i3/{name}: frontmatter ciclo «{thread.ciclo}» non è dev|runtime")
        if not thread.obiettivo:
            errors.append(f"i3/{name}: nessun obiettivo nel frontmatter (obiettivo:)")
        else:
            unknown = [k.strip() for k in thread.obiettivo.split(",") if k.strip() not in keys]
            if unknown:
                errors.append(f"i3/{name}: obiettivi assenti dal register ({', '.join(unknown)})")
        threads.append(thread)
    if errors:
        raise SystemExit("contratto i3 × goal violato:\n- " + "\n- ".join(errors))
    return threads


def parse_task(root: Path, relative: str) -> TaskDetail:
    path = root / relative
    meta, body = split_frontmatter(path.read_text(encoding="utf-8"))
    if not meta.get("sintesi"):
        raise SystemExit(f"{relative}: frontmatter incompleto (sintesi)")
    return TaskDetail(
        path=path,
        title=first_h1(body, path.stem),
        ciclo=meta.get("ciclo", "—"),
        sintesi=meta["sintesi"],
        decidere=meta.get("decidere", ""),
    )


def pending_proposals(root: Path) -> list[tuple[str, TaskDetail]]:
    """I task `o2/` con una proposta da decidere, nell'ordine dell'indice.

    La fonte è il campo `decidere:` del frontmatter: si toglie quando il
    custode decide, così una proposta consumata esce dalla home da sola.
    """
    tasks = [(relative, parse_task(root, relative)) for relative in o2_index(root)]
    return [(relative, task) for relative, task in tasks if task.decidere]


# Gli unici schemi che portano fuori dal checkout senza portarsi dietro il
# disco di chi costruisce: `file:` e i path Windows (`C:\…`, letto come
# schema `c:`) non sono esterni, e il presidio li ferma.
_EXTERNAL_SCHEMES = {"http", "https", "mailto"}


def is_external(target: str) -> bool:
    """Un URL web o mail, o un'ancora: resta link anche fuori dal checkout."""
    parts = urlsplit(target)
    if target.startswith("#"):
        return True
    if parts.scheme:
        return parts.scheme.lower() in _EXTERNAL_SCHEMES
    return target.startswith("//")


def inline_markdown(text: str) -> str:
    """Rende inline markdown (code, bold, link) per la home.

    La vista è chiusa su se stessa (`kb/view.md`): un link relativo
    porterebbe a una fonte fuori da `view/`, quindi se ne
    rende solo l'etichetta. Restano link gli URL con schema e le ancore.
    """
    escaped = html.escape(text)
    escaped = re.sub(r"`([^`]+)`", r"<code>\1</code>", escaped)
    escaped = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", escaped)

    def link(match: re.Match[str]) -> str:
        label_html, href = match.group(1), html.unescape(match.group(2))
        if not is_external(href):
            return label_html
        return f'<a href="{html.escape(href, quote=True)}">{label_html}</a>'

    return re.sub(r"\[([^\]]+)\]\(([^)]+)\)", link, escaped)


# --- Pandoc e compartimento stagno ---------------------------------------------


def pandoc_ast(markdown: str) -> dict:
    """Il Markdown di Pandoc come AST JSON, il formato su cui la build lavora."""
    parsed = subprocess.run(
        ["pandoc", "--from=markdown-native_divs", "--to=json"],
        input=markdown,
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=True,
    )
    return json.loads(parsed.stdout)


def pandoc_render(document: dict, args: list[str]) -> str:
    return subprocess.run(
        ["pandoc", "--from=json", *args],
        input=json.dumps(document),
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=True,
    ).stdout


def _inside(folder: Path, target: str) -> bool:
    path = urlsplit(target).path
    if not path:
        return True
    normal = posixpath.normpath(path)
    return not normal.startswith(("../", "/")) and normal != ".." and (folder / normal).exists()


def close_links(value: object, folder: Path, source: str) -> object:
    """Chiude l'AST del deck dentro `view/`: il compartimento stagno.

    Un link che esce dalla cartella diventa la sua etichetta; un'immagine,
    anche di sfondo, deve stare nella cartella, altrimenti la build rompe:
    una tavola che manca non si rende in silenzio (`kb/view.md`).
    """
    if isinstance(value, list):
        out: list[object] = []
        for child in value:
            closed = close_links(child, folder, source)
            if isinstance(child, dict) and child.get("t") == "Link" and closed is None:
                out.extend(close_links(child["c"][1], folder, source))
            else:
                out.append(closed)
        return out
    if not isinstance(value, dict):
        return value
    kind = value.get("t")
    if kind == "Link":
        target = value["c"][-1][0]
        if not is_external(target) and not _inside(folder, target):
            return None
    if kind == "Image":
        target = value["c"][-1][0]
        if not is_external(target) and not _inside(folder, target):
            raise SystemExit(f"{source}: immagine fuori da view/ o assente — «{target}»")
    if kind == "Header":
        for key, target in value["c"][1][2]:
            if key == "data-background-image" and not _inside(folder, target):
                raise SystemExit(f"{source}: tavola fuori da view/ o assente — «{target}»")
    return {key: close_links(child, folder, source) for key, child in value.items()}


LIVE_ROUTES = ("_ciclo/",)
_URL_ATTR = re.compile(r'(?:href|src|data-background-image)="([^"]*)"|url\(([^)]*)\)')


def check_closed(folder: Path) -> None:
    """Presidio finale: nessun URL emesso esce da `view/` o punta al vuoto."""
    errors: list[str] = []
    # Le pagine ricalcano i path del repo: stanno nelle sottocartelle.
    for page in sorted(folder.rglob("*.html")) + sorted(folder.rglob("*.css")):
        base = page.parent
        for match in _URL_ATTR.finditer(page.read_text(encoding="utf-8")):
            target = html.unescape((match.group(1) or match.group(2) or "").strip("'\""))
            if not target or is_external(target):
                continue
            path = urlsplit(target).path
            # Le rotte che serve.py rende a richiesta (lo stato del ciclo autonomo)
            # non sono file della cartella: la home le nomina dalla root.
            if page.parent == folder and path.startswith(LIVE_ROUTES):
                continue
            resolved = (base / path).resolve()
            if folder.resolve() not in resolved.parents and resolved != folder.resolve():
                errors.append(f"{page.relative_to(folder)}: esce dalla cartella — «{target}»")
            elif not resolved.exists():
                errors.append(f"{page.relative_to(folder)}: destinazione assente — «{target}»")
    if errors:
        raise SystemExit("view/ non è chiusa su se stessa:\n- " + "\n- ".join(errors))


def register_intro(root: Path, name: str) -> str:
    """Intro di un register di polo (`goal.md`/`world.md`): dall'H1 al primo H2.

    È il contratto machine-readable dei register: l'intro è il polo in sintesi,
    reso fedelmente dalla home; le sezioni successive sono profondità on-demand.
    """
    text = (root / f"{name}.md").read_text(encoding="utf-8")
    pattern = re.compile(r"^# .+?\n(?P<body>.*?)(?=^## |\Z)", re.MULTILINE | re.DOTALL)
    match = pattern.search(text)
    if not match or not match.group("body").strip():
        raise SystemExit(f"{name}.md: intro del register mancante (H1 → primo H2)")
    return match.group("body").strip()


def deck_exit() -> str:
    """L'uscita dal deck, da includere dopo `Reveal.initialize`.

    Reveal usa Alt+frecce per saltare i frammenti e toglie l'evento al browser,
    e un solo «indietro» riporta alle viste: Alt+frecce tornano al browser, e un
    link fisso rende visibile l'uscita. Un `DECK_BUILDER` di dominio deve
    includere lo stesso frammento: lo verifica `check_deck_exit`. Sta su una riga
    sola perché il template di pandoc indenterebbe le successive.
    """
    return (
        f'<a class="deck-exit" href="index.html">← {html.escape(label("views"))}</a>'
        "<script>Reveal.configure({keyboardCondition: (event) => !event.altKey});</script>"
    )


def check_deck_exit(page: str) -> None:
    """Un deck senza il frammento non si pubblica: resterebbe senza uscita."""
    if deck_exit() not in page:
        raise SystemExit(
            "deck: manca l'uscita alle viste, includi sources.deck_exit() nella pagina"
        )


def reveal_page(markdown: str, source: str, title: str, reveal_url: str, folder: Path) -> str:
    """Il deck Reveal canonico da Markdown: stile, accento e link chiusi.

    È la resa del deck, e la usa anche un builder di dominio che parte da
    Markdown (`DECK_BUILDER` in `project.py`).
    """
    document = close_links(pandoc_ast(markdown), folder, source)
    return pandoc_render(
        document,
        [
            "--standalone",
            "--to=revealjs",
            "--slide-level=2",
            "--css=assets/deck.css",
            "--css=assets/theme.css",
            *(f"--css=assets/{name}" for name in project.CSS_LOCALI),
            f"--metadata=pagetitle:{title}",
            f"--variable=revealjs-url:{reveal_url}",
            "--variable=theme:white",
            "--variable=width:1180",
            "--variable=height:740",
            "--variable=margin:0.05",
            "--variable=center:false",
            "--variable=slideNumber:true",
            f"--variable=include-after:{deck_exit()}",
        ],
    )
