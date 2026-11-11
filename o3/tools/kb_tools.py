#!/usr/bin/env python3
"""Utility deterministiche per la manutenzione della knowledge base."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
from collections import Counter, defaultdict
from dataclasses import dataclass, asdict
from datetime import date
from pathlib import Path


LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
# Catalogo dei nodi: l'indice interno omonimo kb/kb.md. I link sono nomi piani
# relativi a kb/.
CATALOG_NAME = "kb/kb.md"
CATALOG_KB_RE = re.compile(r"\(([a-z0-9][a-z0-9.-]*\.md)\)")
# Collezioni-stadio: ogni item (indice escluso) porta la facet `ciclo`.
STAGE_INDEXES = {
    "i1": "perceptions.md",
    "i2": "interpretations.md",
    "i3": "verdicts.md",
    "o1": None,  # o1/plan.md è anche l'istanza corrente del Plan.
    "o2": "tasks.md",
    "o3": "prescriptions.md",
}
WORD_RE = re.compile(r"\b[a-zàèéìòù][a-zàèéìòù-]{5,}\b", re.IGNORECASE)
NIX_PATH_RE = re.compile(r"(?<![\w.-])(\.{1,2}/[A-Za-z0-9_./-]+\.nix)")
FLAKE_HOST_RE = re.compile(
    r'^\s+([a-z0-9-]+)\s*=\s*mkHost\s+(?:[\w.-]+\s+)?"[^"]+";', re.MULTILINE
)
FLAKE_HOME_RE = re.compile(r'^\s+"([^"]+)"\s*=\s*mkHome\s+\{', re.MULTILINE)
TABLE_FIRST_CELL_RE = re.compile(r"^\|\s*([^|]+?)\s*\|", re.MULTILINE)
PROJECT_MAP_PROFILE_RE = re.compile(r"`([^`]+@[^`]+)`")
BOLD_LIST_ITEM_RE = re.compile(r"^- \*\*`?([^*`]+)`?\*\*", re.MULTILINE)

# Unicità di livello dei pacchetti (kb/configuration-patterns.md § Pacchetti:
# un solo livello): ogni app vive a system o a home, mai a entrambi.
PKGS_INTERP_RE = re.compile(r"\$\{pkgs\.([a-zA-Z0-9_-]+)\}")
PROGRAMS_ATTR_RE = re.compile(r"^\s*programs\.([a-z][a-zA-Z0-9_-]*)", re.MULTILINE)
NIX_TOKEN_STOPWORDS = {
    "true",
    "false",
    "with",
    "pkgs",
    "lib",
    "let",
    "in",
    "inherit",
    "old",
    "config",
    "enableWideVine",
}
# Eccezioni documentate alla unicità di livello (razionale nel nodo
# kb/configuration-patterns.md): fish è dichiarato a system (disponibilità,
# ponte bash) e a home (configurazione utente); programs.ssh è config-only a
# entrambi i livelli (nessun binario: il client viene dalla base NixOS).
DUAL_LEVEL_ALLOWED = {"fish", "ssh"}

STOPWORDS = {
    "anche",
    "attraverso",
    "caratteristiche",
    "connessioni",
    "corpo",
    "data",
    "della",
    "delle",
    "degli",
    "dell",
    "esperienza",
    "essere",
    "esempi",
    "forma",
    "markdown",
    "maturo",
    "mente",
    "mondo",
    "nella",
    "nelle",
    "nello",
    "nodi",
    "nodo",
    "oggetto",
    "parte",
    "pensiero",
    "pratica",
    "presenza",
    "perché",
    "prima",
    "processo",
    "propria",
    "qualcosa",
    "quella",
    "quelle",
    "quello",
    "questi",
    "questa",
    "questo",
    "quando",
    "realtà",
    "relazione",
    "senza",
    "sofferenza",
    "stato",
    "stessa",
    "stesso",
    "tradizione",
    "tradizioni",
    "verso",
    "viene",
    "vuoto",
    "richiede",
    "diretta",
}


@dataclass(frozen=True)
class Facet:
    """Attributo intrinseco di dominio di un nodo (faceted classification).

    `values` è l'insieme chiuso dei valori ammessi; `required=True` esige la facet
    su ogni nodo (es. `ciclo` sugli item di collezione), `False` ne verifica solo il dominio quando presente. Il criterio dei quattro
    requisiti che legittima una facet vive in `method/node.md`.
    """

    values: frozenset[str]
    required: bool = False


# Attributi di dominio dichiarati dall'adottante nixos. Il backend del meccanismo
# è portabile dal metodo; qui si parametrizza, come per CATALOG_NAME o DOC_DIRS.
# Vuoto dal 2026-11-05: `mondo: lavoro | casa | trasversale` ha reso meccanico lo
# split dei repository ed è uscita col suo scopo, a separazione fatta (in un repo
# di sola casa non distingue più nulla). Il meccanismo resta per facet future.
EXTENDED_FACETS: dict[str, Facet] = {}
CYCLE_FACET = Facet(frozenset({"dev", "runtime"}), required=True)


@dataclass
class AuditResult:
    total_nodes: int
    total_links: int
    catalog_links: int
    catalog_unique_links: int
    catalog_broken: list[str]
    catalog_missing_nodes: list[str]
    broken_links: list[str]
    orphans: list[str]
    isolated: list[str]
    cross_folder: list[str]
    accented_names: list[str]
    invalid_names: list[str]
    frontmatter_count: int
    connessioni_count: int
    body_inline_links: list[str]
    footer_duplicates: list[str]
    non_node_broken_links: list[str]
    clusters_total: int
    cluster_isolated: list[str]
    cluster_out_counts: dict[str, int]
    term_candidates: list[dict[str, int | str]]
    hubs: list[dict[str, int | str]]
    recent_commits: list[str]
    facet_violations: list[str]
    stage_cycle_count: int


@dataclass
class InventoryResult:
    hosts: list[str]
    home_profiles: list[str]
    modules_total: int
    modules: list[str]
    imported_modules: list[str]
    dead_modules: list[str]


@dataclass
class FactsResult:
    host_inventory: list[str]
    readme_hosts: list[str]
    project_map_hosts: list[str]
    home_profile_inventory: list[str]
    project_map_profiles: list[str]
    modules_total: int
    checks: list[dict[str, object]]


@dataclass
class CoverageResult:
    host_checks: list[dict[str, object]]
    module_warnings: list[dict[str, str]]
    home_cli_warnings: list[dict[str, str]]
    macro_area_checks: list[dict[str, object]]
    family_summary: list[dict[str, object]]


@dataclass
class FidelityResult:
    summary: dict[str, int]
    signals: list[dict[str, str]]
    semantic_review: dict[str, object]


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def deaccent(value: str) -> str:
    return value.translate(str.maketrans("àèéìòù", "aeeiou"))


def markdown_links(text: str) -> list[str]:
    return [target for target in LINK_RE.findall(text) if target.endswith(".md")]


def kb_files(root: Path) -> list[Path]:
    # Esclude l'indice di collezione omonimo (kb/kb.md): è il catalogo, non un nodo.
    return sorted(p for p in (root / "kb").glob("*.md") if p.name != "kb.md")


def tech_files(root: Path) -> list[Path]:
    return sorted((root / "tech").glob("*.md"))


def nix_files(root: Path) -> list[Path]:
    folders = [root / "o3" / "hosts", root / "o3" / "home", root / "o3" / "modules"]
    return sorted(path for folder in folders for path in folder.rglob("*.nix"))


def module_files(root: Path) -> list[Path]:
    return sorted((root / "o3" / "modules").rglob("*.nix"))


def link_map(root: Path) -> tuple[dict[str, list[str]], list[str]]:
    inventory = {p.name for p in kb_files(root)}
    links: dict[str, list[str]] = {}
    broken: list[str] = []

    for path in kb_files(root):
        targets: list[str] = []
        for target in markdown_links(path.read_text(encoding="utf-8")):
            if "://" in target or target.startswith("#"):
                continue
            if "/" in target:
                resolved = (path.parent / target).resolve()
                if not resolved.exists():
                    broken.append(f"{path.name} -> {target}")
                continue
            targets.append(target)
            if target not in inventory:
                broken.append(f"{path.name} -> {target}")
        links[path.name] = targets

    return links, broken


def backlink_map(
    links: dict[str, list[str]], inventory: set[str]
) -> dict[str, set[str]]:
    backlinks: dict[str, set[str]] = defaultdict(set)
    for source, targets in links.items():
        for target in targets:
            if target in inventory and target != source:
                backlinks[target].add(source)
    return backlinks


def catalog_index(root: Path) -> tuple[list[str], list[str], list[str]]:
    catalog = root / CATALOG_NAME
    text = catalog.read_text(encoding="utf-8") if catalog.exists() else ""
    paths = [f"kb/{target}" for target in CATALOG_KB_RE.findall(text)]
    broken = [path for path in paths if not (root / path).exists()]
    indexed = set(paths)
    missing = sorted(
        f"kb/{path.name}" for path in kb_files(root) if f"kb/{path.name}" not in indexed
    )
    return paths, broken, missing


def cross_folder_links(root: Path) -> list[str]:
    findings: list[str] = []
    checks = [
        (root / "kb", [r"\]\(\.\./tech/", r"\]\(tech/"]),
        (root / "tech", [r"\]\(\.\./kb/", r"\]\(kb/"]),
    ]
    for folder, patterns in checks:
        for path in sorted(folder.glob("*.md")):
            for lineno, line in enumerate(
                path.read_text(encoding="utf-8").splitlines(), 1
            ):
                if any(re.search(pattern, line) for pattern in patterns):
                    findings.append(
                        f"{path.relative_to(root)}:{lineno}: {line.strip()}"
                    )
    return findings


def filename_findings(root: Path) -> tuple[list[str], list[str]]:
    accented: list[str] = []
    invalid: list[str] = []
    for path in sorted(kb_files(root) + tech_files(root)):
        rel = str(path.relative_to(root))
        if re.search(r"[A-Z ]", rel):
            invalid.append(rel)
            continue
        if re.search(r"[^a-z0-9./\-]", rel):
            if all(
                char.islower() or char.isdigit() or char in "./-" or ord(char) > 127
                for char in rel
            ):
                accented.append(rel)
            else:
                invalid.append(rel)
    return accented, invalid


def migration_state(root: Path) -> tuple[int, int, list[str]]:
    frontmatter = 0
    connessioni = 0
    body_inline: list[str] = []
    for path in kb_files(root):
        text = path.read_text(encoding="utf-8")
        fm = (
            text.split("---", 2)[1]
            if text.startswith("---\n") and text.count("---") >= 2
            else ""
        )
        if text.startswith("---\n") and "\nstato:" in fm:
            frontmatter += 1
        if "\nConnessioni:\n" in text:
            connessioni += 1
        body = text.split("\nConnessioni:\n", 1)[0]
        # Il corpo deve restare prosa pura: il vincolo vale per ogni link
        # Markdown, non soltanto per i collegamenti interni a file `.md`.
        if LINK_RE.search(body):
            body_inline.append(path.name)
    return frontmatter, connessioni, body_inline


# Cartelle escluse dal walk di `markdown_sources`: strumenti, cache locali e
# metadata editor, oltre alle convenzioni già gitignored del repo (cache/,
# secrets/, .agents/).
MARKDOWN_WALK_EXCLUDE = {
    ".git",
    ".direnv",
    ".venv",
    "node_modules",
    "__pycache__",
    "cache",
    "secrets",
    ".agents",
}


def markdown_sources(root: Path) -> list[Path]:
    """Tutti i markdown versionati del repository. `os.walk` non segue i symlink,
    così `method/` e le altre superfici della membrana restano fuori
    dall'artefatto senza doverle nominare qui."""
    files: list[Path] = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [
            name
            for name in dirnames
            if not name.startswith(".") and name not in MARKDOWN_WALK_EXCLUDE
        ]
        files.extend(Path(dirpath) / name for name in filenames if name.endswith(".md"))
    return sorted(files)


def non_node_broken_links(root: Path) -> list[str]:
    """Link morti nei markdown che non sono nodi `kb/`: register dei poli,
    bussola, regole operative e indici delle collezioni. `link_map` copre
    soltanto l'inventario dei nodi, quindi un riferimento a un filo rimosso
    resterebbe altrimenti invisibile."""
    checked = {path.resolve() for path in kb_files(root)}
    catalog = root / CATALOG_NAME
    if catalog.exists():
        checked.add(catalog.resolve())

    findings: list[str] = []
    for path in markdown_sources(root):
        if path.resolve() in checked:
            continue
        for target in markdown_links(path.read_text(encoding="utf-8")):
            if "://" in target or target.startswith("#"):
                continue
            resolved = (path.parent / target.split("#", 1)[0]).resolve()
            if not resolved.exists():
                findings.append(f"{path.relative_to(root)} -> {target}")
    return findings


def footer_duplicates(root: Path) -> list[str]:
    """Link ripetuti nella sezione Connessioni: le connessioni sono deduplicate,
    ma un target ripetuto resta invisibile al conteggio dei link e al catalogo."""
    findings: list[str] = []
    for path in kb_files(root):
        text = path.read_text(encoding="utf-8")
        if "\nConnessioni:\n" not in text:
            continue
        footer = text.split("\nConnessioni:\n", 1)[1]
        counts = Counter(markdown_links(footer))
        for target, count in sorted(counts.items()):
            if count > 1:
                findings.append(f"{path.name} -> {target} (x{count})")
    return findings


def frontmatter_block(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    return (
        text.split("---", 2)[1]
        if text.startswith("---\n") and text.count("---") >= 2
        else ""
    )


def facet_value(fm: str, name: str) -> str | None:
    match = re.search(rf"(?m)^{re.escape(name)}:[ \t]*(.+?)[ \t]*$", fm)
    return match.group(1).strip() if match else None


def validate_facet(
    key: str, fm: str, name: str, facet: Facet, violations: list[str]
) -> None:
    value = facet_value(fm, name)
    if value is None:
        if facet.required:
            violations.append(f"{key}: manca `{name}`")
        return
    if value not in facet.values:
        violations.append(
            f"{key}: `{name}: {value}` fuori dominio {sorted(facet.values)}"
        )


def facet_violations(root: Path) -> list[str]:
    """Verifica gli attributi di dominio dichiarati in EXTENDED_FACETS.

    Per ogni facet controlla che il valore nel frontmatter sia dentro il dominio
    chiuso; se la facet è `required`, ne esige anche la presenza su ogni nodo.
    """
    if not EXTENDED_FACETS:
        return []
    violations: list[str] = []
    for path in kb_files(root):
        fm = frontmatter_block(path)
        for name, facet in EXTENDED_FACETS.items():
            validate_facet(path.name, fm, name, facet, violations)
    return violations


def stage_cycle_state(root: Path) -> tuple[int, list[str]]:
    """Verifica la facet `ciclo` sugli item delle collezioni-stadio.

    In `o2/` esige anche `sintesi` e segnala `stato:` come residuo: un task in
    `o2/` è aperto per esistenza (canone 2026-07-04).
    """
    checked = 0
    violations: list[str] = []
    for dirname, index_name in STAGE_INDEXES.items():
        directory = root / dirname
        if not directory.is_dir():
            continue
        for path in sorted(directory.glob("*.md")):
            if index_name and path.name == index_name:
                continue
            checked += 1
            key = f"{dirname}/{path.name}"
            fm = frontmatter_block(path)
            validate_facet(key, fm, "ciclo", CYCLE_FACET, violations)
            if dirname == "o2":
                if facet_value(fm, "sintesi") is None:
                    violations.append(f"{key}: manca `sintesi`")
                if facet_value(fm, "stato") is not None:
                    violations.append(
                        f"{key}: `stato` presente (soppresso: un task in o2/ "
                        "è aperto per esistenza)"
                    )
    return checked, violations


def cluster_state(
    root: Path, links: dict[str, list[str]]
) -> tuple[dict[str, set[str]], dict[str, set[str]]]:
    catalog = root / CATALOG_NAME
    text = catalog.read_text(encoding="utf-8") if catalog.exists() else ""
    clusters: dict[str, set[str]] = defaultdict(set)
    current: str | None = None
    for line in text.splitlines():
        heading = re.match(r"## (.+)", line)
        if heading:
            title = heading.group(1).strip()
            current = title
            continue
        if line.startswith("# "):
            current = None
        if current:
            for target in CATALOG_KB_RE.findall(line):
                clusters[current].add(Path(target).name)

    node_cluster: dict[str, str] = {}
    for cluster, nodes in clusters.items():
        for node in nodes:
            node_cluster.setdefault(node, cluster)

    cluster_out: dict[str, set[str]] = defaultdict(set)
    for source, targets in links.items():
        source_cluster = node_cluster.get(source)
        if not source_cluster:
            continue
        for target in targets:
            target_cluster = node_cluster.get(target)
            if target_cluster and target_cluster != source_cluster:
                cluster_out[source_cluster].add(target_cluster)
    return clusters, cluster_out


def term_candidates(root: Path, limit: int = 12) -> list[dict[str, int | str]]:
    existing = {path.stem for path in kb_files(root)}
    file_occurrences: dict[str, set[str]] = defaultdict(set)
    total_occurrences: Counter[str] = Counter()

    for path in kb_files(root):
        text = path.read_text(encoding="utf-8").lower()
        if text.startswith("---"):
            text = text.split("---", 2)[2]
        text = text.split("\nconnessioni:\n", 1)[0]
        for word in WORD_RE.findall(text):
            word = word.strip("-").lower()
            singular = word[:-1] if word.endswith("i") else word
            singular_e = f"{word[:-1]}e" if word.endswith("i") else word
            if word in STOPWORDS or deaccent(word) in STOPWORDS:
                continue
            if word in existing or deaccent(word) in existing:
                continue
            if singular in existing or deaccent(singular) in existing:
                continue
            if singular_e in existing or deaccent(singular_e) in existing:
                continue
            file_occurrences[word].add(path.name)
            total_occurrences[word] += 1

    candidates = [
        {"termine": word, "file": len(files), "occorrenze": total_occurrences[word]}
        for word, files in file_occurrences.items()
        if len(files) >= 5 and total_occurrences[word] >= 10
    ]
    return sorted(
        candidates,
        key=lambda item: (int(item["file"]), int(item["occorrenze"])),
        reverse=True,
    )[:limit]


def recent_commits(root: Path) -> list[str]:
    try:
        output = subprocess.check_output(
            ["git", "log", "--oneline", "-15"], cwd=root, text=True
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return []
    return [line for line in output.splitlines() if line.strip()]


def flake_inventory(root: Path) -> tuple[list[str], list[str]]:
    text = (root / "flake.nix").read_text(encoding="utf-8")
    return sorted(FLAKE_HOST_RE.findall(text)), sorted(FLAKE_HOME_RE.findall(text))


def imported_modules(root: Path) -> list[str]:
    modules_root = (root / "o3" / "modules").resolve()
    imported: set[str] = set()
    for path in nix_files(root):
        text = path.read_text(encoding="utf-8")
        for raw_target in NIX_PATH_RE.findall(text):
            resolved = (path.parent / raw_target).resolve()
            if resolved.is_relative_to(modules_root) and resolved.exists():
                imported.add(str(resolved.relative_to(root)))
    return sorted(imported)


def run_inventory(root: Path) -> InventoryResult:
    hosts, profiles = flake_inventory(root)
    modules = [str(path.relative_to(root)) for path in module_files(root)]
    imported = imported_modules(root)
    return InventoryResult(
        hosts=hosts,
        home_profiles=profiles,
        modules_total=len(modules),
        modules=modules,
        imported_modules=imported,
        dead_modules=sorted(set(modules) - set(imported)),
    )


def readme_hosts(root: Path) -> list[str]:
    text = (root / "README.md").read_text(encoding="utf-8")
    section = text.split("## Host\n", 1)[1].split("\n## ", 1)[0]
    return sorted(
        {
            cell
            for cell in (
                TABLE_FIRST_CELL_RE.findall(section)
                + BOLD_LIST_ITEM_RE.findall(section)
            )
            if re.fullmatch(r"[a-z][a-z0-9-]*", cell) and cell != "host"
        }
    )


def project_map_hosts(root: Path) -> list[str]:
    text = (root / "world.md").read_text(encoding="utf-8")
    section = text.split("## Host e ruoli\n", 1)[1].split("\n## ", 1)[0]
    return sorted(
        {
            cell
            for cell in (
                TABLE_FIRST_CELL_RE.findall(section)
                + BOLD_LIST_ITEM_RE.findall(section)
            )
            if re.fullmatch(r"[a-z][a-z0-9-]*", cell) and cell != "host"
        }
    )


def project_map_profiles(root: Path) -> list[str]:
    text = (root / "world.md").read_text(encoding="utf-8")
    section = text.split("## Profili home-manager\n", 1)[1].split("\n## ", 1)[0]
    return sorted(PROJECT_MAP_PROFILE_RE.findall(section))


def project_text_corpus(root: Path) -> str:
    texts = [
        (root / "README.md").read_text(encoding="utf-8"),
        *[path.read_text(encoding="utf-8") for path in kb_files(root)],
    ]
    return "\n".join(texts).lower()


def important_module(module: str) -> bool:
    path = Path(module)
    if module.startswith("o3/modules/system/services/"):
        return True
    return path.name in {
        "server-role.nix",
        "gaming.nix",
        "niri.nix",
        "rclone.nix",
        "gui-apps.nix",
    }


def module_mentions(module: str, corpus: str) -> bool:
    path = module.lower()
    stem = Path(module).stem.lower()
    basename = Path(module).name.lower()
    short_path = path.removeprefix("o3/modules/system/").removeprefix(
        "o3/modules/home/"
    )
    candidates = {path, short_path, basename, stem}
    return any(candidate in corpus for candidate in candidates)


def home_cli_module(root: Path, module: str) -> bool:
    if not module.startswith("o3/modules/home/"):
        return False
    text = (root / module).read_text(encoding="utf-8")
    return "writeShellScriptBin" in text or "writeScriptBin" in text


def module_family(module: str) -> str:
    if module.startswith("o3/modules/system/services/"):
        return "o3/modules/system/services"
    if module.startswith("o3/modules/system/hardware/"):
        return "o3/modules/system/hardware"
    if module.startswith("o3/modules/system/"):
        return "o3/modules/system"
    if module.startswith("o3/modules/home/"):
        return "o3/modules/home"
    return "o3/modules/other"


def parse_project_map_macro_areas(root: Path) -> list[dict[str, object]]:
    text = (root / "world.md").read_text(encoding="utf-8")
    if "## Macro-aree del sistema\n" not in text:
        return []
    section = text.split("## Macro-aree del sistema\n", 1)[1].split("\n## ", 1)[0]
    rows: list[dict[str, object]] = []
    for line in section.splitlines():
        if not line.startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if len(cells) != 3:
            continue
        area, sources, nodes = cells
        if area.lower() == "area" or set(area) <= {"-"}:
            continue
        source_refs = re.findall(r"`([^`]+)`", sources)
        source_entries = source_refs or [sources]
        node_refs = [
            item.strip()
            for item in re.split(r",\s*", nodes)
            if item.strip() and not set(item.strip()) <= {"-"}
        ]
        rows.append(
            {
                "area": area,
                "sources": source_entries,
                "source_refs": source_refs,
                "kb_nodes": node_refs,
            }
        )
    if rows:
        return rows

    current: dict[str, object] | None = None
    for line in section.splitlines():
        area_match = re.match(r"^- \*\*([^*]+)\*\*", line)
        if area_match:
            if current:
                rows.append(current)
            current = {
                "area": area_match.group(1),
                "sources": [],
                "source_refs": [],
                "kb_nodes": [],
            }
            continue
        if current is None:
            continue
        stripped = line.strip()
        if stripped.startswith("- Fonte di verità tecnica:"):
            value = stripped.split(":", 1)[1].strip()
            refs = re.findall(r"`([^`]+)`", value)
            current["sources"] = refs or [value]
            current["source_refs"] = refs
        elif stripped.startswith("- Nodi KB:"):
            value = stripped.split(":", 1)[1].strip()
            current["kb_nodes"] = [
                item.strip(" `") for item in value.split(",") if item.strip(" `")
            ]
    if current:
        rows.append(current)
    return rows


def node_exists(root: Path, node: str) -> bool:
    normalized = node.strip()
    if normalized.endswith(".md"):
        return (root / "kb" / normalized).exists() or (
            root / "method" / normalized
        ).exists()
    return (root / "kb" / f"{normalized}.md").exists() or (
        root / "method" / f"{normalized}.md"
    ).exists()


def source_exists(root: Path, source: str) -> bool:
    if "*" in source:
        prefix = source.split("*", 1)[0]
        return any(
            (root / source_path).exists() for source_path in root.glob(f"{prefix}*")
        )
    return (root / source).exists()


def comparison_check(
    name: str, expected: list[str], documented: list[str]
) -> dict[str, object]:
    return {
        "name": name,
        "ok": expected == documented,
        "expected": expected,
        "documented": documented,
        "missing": sorted(set(expected) - set(documented)),
        "extra": sorted(set(documented) - set(expected)),
    }


def _bracket_block(text: str, start: int) -> str:
    depth = 0
    i = start
    while i < len(text):
        if text[i] == "[":
            depth += 1
        elif text[i] == "]":
            depth -= 1
            if depth == 0:
                break
        i += 1
    return text[start:i]


def package_list_names(text: str, attr: str) -> set[str]:
    """Nomi di pacchetto nel primo blocco lista dell'attributo (euristica:
    le code `++ lib.optionals ... [...]` non sono attraversate)."""
    names: set[str] = set()
    for match in re.finditer(
        re.escape(attr) + r"\s*=\s*(?:with\s+[\w.-]+;\s*)?\[", text
    ):
        block = re.sub(r"#.*", "", _bracket_block(text, match.end() - 1))
        for token in re.findall(r"[\w.-]+", block):
            token = token.removeprefix("pkgs.")
            if "." in token or token in NIX_TOKEN_STOPWORDS:
                continue
            if re.fullmatch(r"[a-zA-Z][\w-]*", token):
                names.add(token)
    return names


def system_home_level_overlap(root: Path) -> dict[str, list[str]]:
    """Verifica l'unicità di livello: pacchetti e programs.* dichiarati sia a
    system che a home, e riferimenti home a pacchetti GUI/desktop di sistema."""
    system_pkgs: set[str] = set()
    home_pkgs: set[str] = set()
    system_programs: set[str] = set()
    home_programs: set[str] = set()
    home_interpolations: set[str] = set()
    for path in nix_files(root):
        rel = path.relative_to(root).as_posix()
        text = path.read_text(encoding="utf-8")
        no_comments = re.sub(r"#.*", "", text)
        if rel.startswith(("o3/modules/system/", "o3/hosts/")):
            system_pkgs |= package_list_names(text, "environment.systemPackages")
            system_programs |= set(PROGRAMS_ATTR_RE.findall(no_comments))
        elif rel.startswith(("o3/modules/home/", "o3/home/")):
            home_pkgs |= package_list_names(text, "home.packages")
            home_programs |= set(PROGRAMS_ATTR_RE.findall(no_comments))
            home_interpolations |= set(PKGS_INTERP_RE.findall(text))
    gui_pkgs: set[str] = set()
    for name in ("gui-apps.nix", "niri.nix", "gaming.nix"):
        path = root / "o3" / "modules" / "system" / name
        if path.exists():
            gui_pkgs |= package_list_names(
                path.read_text(encoding="utf-8"), "environment.systemPackages"
            )
    return {
        "package_overlap": sorted((system_pkgs & home_pkgs) - DUAL_LEVEL_ALLOWED),
        "programs_overlap": sorted(
            (system_programs & home_programs) - DUAL_LEVEL_ALLOWED
        ),
        "gui_refs_from_home": sorted(home_interpolations & gui_pkgs),
    }


def zero_violations_check(name: str, violations: list[str]) -> dict[str, object]:
    return {
        "name": name,
        "ok": not violations,
        "expected": [],
        "documented": violations,
        "missing": [],
        "extra": violations,
    }


def run_facts(root: Path) -> FactsResult:
    inventory = run_inventory(root)
    readme_host_list = readme_hosts(root)
    project_map_host_list = project_map_hosts(root)
    project_map_profile_list = project_map_profiles(root)
    level_overlap = system_home_level_overlap(root)
    checks = [
        comparison_check("readme_hosts", inventory.hosts, readme_host_list),
        comparison_check("project_map_hosts", inventory.hosts, project_map_host_list),
        comparison_check(
            "project_map_home_profiles",
            inventory.home_profiles,
            project_map_profile_list,
        ),
        {
            "name": "zero_dead_modules",
            "ok": not inventory.dead_modules,
            "expected": [],
            "documented": inventory.dead_modules,
            "missing": [],
            "extra": inventory.dead_modules,
        },
        zero_violations_check(
            "package_level_uniqueness", level_overlap["package_overlap"]
        ),
        zero_violations_check(
            "programs_level_uniqueness", level_overlap["programs_overlap"]
        ),
        zero_violations_check(
            "home_refs_to_system_gui", level_overlap["gui_refs_from_home"]
        ),
    ]
    return FactsResult(
        host_inventory=inventory.hosts,
        readme_hosts=readme_host_list,
        project_map_hosts=project_map_host_list,
        home_profile_inventory=inventory.home_profiles,
        project_map_profiles=project_map_profile_list,
        modules_total=inventory.modules_total,
        checks=checks,
    )


def run_coverage(root: Path) -> CoverageResult:
    inventory = run_inventory(root)
    facts = run_facts(root)
    corpus = project_text_corpus(root)

    module_warnings = [
        {
            "module": module,
            "reason": "active important module not mentioned in README or KB",
        }
        for module in inventory.imported_modules
        if important_module(module) and not module_mentions(module, corpus)
    ]

    home_cli_warnings = [
        {
            "module": module,
            "reason": "home-manager CLI wrapper not mentioned in README or KB",
        }
        for module in inventory.imported_modules
        if home_cli_module(root, module) and not module_mentions(module, corpus)
    ]

    family_counts = Counter(module_family(module) for module in inventory.modules)
    family_imported_counts = Counter(
        module_family(module) for module in inventory.imported_modules
    )
    family_summary = [
        {
            "family": family,
            "modules": family_counts[family],
            "imported_modules": family_imported_counts[family],
        }
        for family in sorted(family_counts)
    ]

    macro_area_checks = []
    for row in parse_project_map_macro_areas(root):
        sources = list(row["sources"])
        source_refs = list(row["source_refs"])
        nodes = list(row["kb_nodes"])
        missing_sources = [
            source
            for source in source_refs
            if source.startswith(("o3/hosts/", "o3/home/", "o3/modules/", "flake."))
            and not source_exists(root, source)
        ]
        missing_nodes = [node for node in nodes if not node_exists(root, node)]
        macro_area_checks.append(
            {
                "area": row["area"],
                "ok": bool(sources)
                and bool(nodes)
                and not missing_sources
                and not missing_nodes,
                "sources": sources,
                "kb_nodes": nodes,
                "missing_sources": missing_sources,
                "missing_nodes": missing_nodes,
            }
        )

    return CoverageResult(
        host_checks=[
            check
            for check in facts.checks
            if check["name"]
            in {
                "readme_hosts",
                "project_map_hosts",
                "project_map_home_profiles",
            }
        ],
        module_warnings=module_warnings,
        home_cli_warnings=home_cli_warnings,
        macro_area_checks=macro_area_checks,
        family_summary=family_summary,
    )


def run_fidelity(root: Path) -> FidelityResult:
    facts = run_facts(root)
    coverage = run_coverage(root)
    signals: list[dict[str, str]] = []

    for check in facts.checks:
        if not check["ok"]:
            signals.append(
                {
                    "level": "error",
                    "code": f"FACT-{str(check['name']).upper()}",
                    "message": f"Fact check failed: {check['name']}",
                    "source": "facts",
                }
            )

    for check in coverage.macro_area_checks:
        if not check["ok"]:
            signals.append(
                {
                    "level": "error",
                    "code": "MACRO-AREA-INCOMPLETE",
                    "message": f"Macro-area incomplete or stale: {check['area']}",
                    "source": "coverage",
                }
            )

    for warning in coverage.module_warnings:
        signals.append(
            {
                "level": "warning",
                "code": "MODULE-NOT-MENTIONED",
                "message": warning["module"],
                "source": "coverage",
            }
        )

    for warning in coverage.home_cli_warnings:
        signals.append(
            {
                "level": "warning",
                "code": "HOME-CLI-NOT-MENTIONED",
                "message": warning["module"],
                "source": "coverage",
            }
        )

    summary = Counter(signal["level"] for signal in signals)
    return FidelityResult(
        summary={
            "errors": summary["error"],
            "warnings": summary["warning"],
            "notes": summary["note"],
        },
        signals=signals,
        semantic_review={
            "required": True,
            "checklist": "method/cognitive-fidelity.md",
            "note": "Zero signals means no deterministic drift detected, not semantic perfection.",
        },
    )


def run_audit(root: Path) -> AuditResult:
    inventory = {path.name for path in kb_files(root)}
    links, broken = link_map(root)
    backlinks = backlink_map(links, inventory)
    catalog_paths, catalog_broken, catalog_missing = catalog_index(root)
    accented, invalid = filename_findings(root)
    frontmatter, connessioni, body_inline = migration_state(root)
    clusters, cluster_out = cluster_state(root, links)
    stage_cycle_count, stage_cycle_issues = stage_cycle_state(root)

    orphans = sorted(node for node in inventory if not backlinks[node])
    isolated = sorted(
        node
        for node in inventory
        if len(links.get(node, [])) == 0 and len(backlinks[node]) <= 1
    )
    hubs = [
        {"nodo": node, "backlink": count}
        for count, node in sorted(
            ((len(sources), node) for node, sources in backlinks.items()), reverse=True
        )[:10]
    ]

    return AuditResult(
        total_nodes=len(inventory),
        total_links=sum(len(targets) for targets in links.values()),
        catalog_links=len(catalog_paths),
        catalog_unique_links=len(set(catalog_paths)),
        catalog_broken=catalog_broken,
        catalog_missing_nodes=catalog_missing,
        broken_links=broken,
        orphans=orphans,
        isolated=isolated,
        cross_folder=cross_folder_links(root),
        accented_names=accented,
        invalid_names=sorted(set(invalid)),
        frontmatter_count=frontmatter,
        connessioni_count=connessioni,
        body_inline_links=body_inline,
        footer_duplicates=footer_duplicates(root),
        non_node_broken_links=non_node_broken_links(root),
        clusters_total=len(clusters),
        cluster_isolated=sorted(
            cluster for cluster in clusters if not cluster_out.get(cluster)
        ),
        cluster_out_counts={
            cluster: len(cluster_out.get(cluster, set()))
            for cluster in sorted(clusters)
        },
        term_candidates=term_candidates(root),
        hubs=hubs,
        recent_commits=recent_commits(root),
        facet_violations=[*facet_violations(root), *stage_cycle_issues],
        stage_cycle_count=stage_cycle_count,
    )


def markdown_report(result: AuditResult) -> str:
    problem_count = (
        len(result.orphans)
        + len(result.broken_links)
        + len(result.catalog_broken)
        + len(result.catalog_missing_nodes)
        + len(result.cross_folder)
        + len(result.invalid_names)
        + len(result.cluster_isolated)
        + len(result.body_inline_links)
        + len(result.footer_duplicates)
        + len(result.non_node_broken_links)
        + len(result.facet_violations)
    )
    lines = [
        f"## [{date.today().isoformat()}] lint | audit completo — {len(result.orphans)} orfane, {len(result.broken_links)} link rotti, {problem_count} problemi",
        "",
        f"## [{date.today().isoformat()}] kb",
        "",
        "### OK",
        "",
        f"- {result.total_nodes} nodi verificati in `kb/`",
        f"- {result.total_links} link interni tra nodi, {len(result.broken_links)} link rotti",
        f"- {result.catalog_links} link {CATALOG_NAME} validi ({result.catalog_unique_links} unici, {result.catalog_links - result.catalog_unique_links} duplicati intenzionali)",
        f"- {result.total_nodes - len(result.catalog_missing_nodes)} nodi con voce in {CATALOG_NAME}",
        f"- {result.stage_cycle_count} item di collezione con facet `ciclo` verificata",
        f"- {result.clusters_total - len(result.cluster_isolated)} cluster con connessioni cross-cluster",
        f"- {len(result.cross_folder)} link cross-folder kb/ ↔ tech/",
        f"- {result.frontmatter_count}/{result.total_nodes} nodi con frontmatter `stato`",
        f"- {result.connessioni_count}/{result.total_nodes} nodi con footer `Connessioni:`",
        f"- {len(result.body_inline_links)} link markdown rimasti nel corpo dei nodi",
        f"- {len(result.footer_duplicates)} link ripetuti in `Connessioni:`",
        f"- {len(result.non_node_broken_links)} link rotti fuori dai nodi (register, bussola, indici)",
        f"- {len(result.isolated)} nodi isolati (0 out e 0/1 in)",
        *(
            [
                f"- attributi di dominio: {', '.join(EXTENDED_FACETS)} "
                f"({len(result.facet_violations)} violazioni)"
            ]
            if EXTENDED_FACETS
            else []
        ),
        "",
        "### Problemi",
        "",
    ]

    problems: list[str] = []
    problems += [
        f"- [ORFANO-LINK] {node} — nessun altro file lo linka"
        for node in result.orphans
    ]
    problems += [f"- [LINK-ROTTO] {item}" for item in result.broken_links]
    problems += [
        f"- [CATALOGO-LINK-ROTTO] {CATALOG_NAME} → {item}"
        for item in result.catalog_broken
    ]
    problems += [
        f"- [NODO-NON-INDICIZZATO] {item}" for item in result.catalog_missing_nodes
    ]
    problems += [f"- [CROSS-FOLDER] {item}" for item in result.cross_folder]
    problems += [f"- [NOME-INVALIDO] {item}" for item in result.invalid_names]
    problems += [f"- [CLUSTER-ISOLATO] {item}" for item in result.cluster_isolated]
    problems += [f"- [LINK-INLINE-CORPO] {item}" for item in result.body_inline_links]
    problems += [
        f"- [CONNESSIONE-DUPLICATA] {item}" for item in result.footer_duplicates
    ]
    problems += [
        f"- [LINK-ROTTO-FUORI-NODI] {item}" for item in result.non_node_broken_links
    ]
    problems += [f"- [FACET] {item}" for item in result.facet_violations]
    lines += problems[:20] if problems else ["- Nessun problema strutturale rilevato"]
    if len(problems) > 20:
        lines.append(f"- ... altri {len(problems) - 20} problemi non mostrati")

    lines += [
        "",
        "### Nomi file",
        "",
        f"- {len(result.accented_names)} file usano caratteri accentati nel nome: {', '.join(Path(item).name for item in result.accented_names) if result.accented_names else 'nessuno'}",
        f"- {len(result.invalid_names)} violazioni di maiuscole, spazi o caratteri non ammessi",
        "",
        "### Concetti ricorrenti senza nodo",
        "",
    ]
    if result.term_candidates:
        lines += [
            f"- {item['termine']} — appare in {item['file']} file, {item['occorrenze']} occorrenze"
            for item in result.term_candidates
        ]
    else:
        lines.append("- Nessun candidato forte")

    lines += [
        "",
        "### Hub principali",
        "",
    ]
    lines += [f"- {item['nodo']} — {item['backlink']} backlink" for item in result.hubs]
    lines += [
        "",
        "### Sintesi",
        "",
        "KB in buona salute strutturale. Usa i problemi elencati sopra come coda di manutenzione; i candidati terminologici richiedono valutazione semantica prima di creare nuovi nodi.",
    ]
    return "\n".join(lines) + "\n"


def print_json(data: object) -> None:
    print(json.dumps(data, ensure_ascii=False, indent=2))


def command_audit(args: argparse.Namespace) -> None:
    root = repo_root()
    result = run_audit(root)
    if args.format == "json":
        output = json.dumps(asdict(result), ensure_ascii=False, indent=2)
    else:
        output = markdown_report(result)
    print(output, end="" if output.endswith("\n") else "\n")


def command_backlinks(args: argparse.Namespace) -> None:
    root = repo_root()
    node = Path(args.node).name
    links, broken = link_map(root)
    inventory = {path.name for path in kb_files(root)}
    if node not in inventory:
        raise SystemExit(f"Nodo non trovato: {node}")
    backlinks = backlink_map(links, inventory)
    data = {
        "nodo": node,
        "out": links.get(node, []),
        "in": sorted(backlinks.get(node, set())),
        "broken_total": len(broken),
    }
    print_json(data)


def command_orphans(args: argparse.Namespace) -> None:
    root = repo_root()
    inventory = {path.name for path in kb_files(root)}
    links, _ = link_map(root)
    backlinks = backlink_map(links, inventory)
    for node in sorted(node for node in inventory if not backlinks[node]):
        print(node)


def command_readme(args: argparse.Namespace) -> None:
    root = repo_root()
    paths, broken, missing = catalog_index(root)
    print_json(
        {
            "links": len(paths),
            "unique": len(set(paths)),
            "broken": broken,
            "missing_nodes": missing,
        }
    )


def command_migration(args: argparse.Namespace) -> None:
    root = repo_root()
    total = len(kb_files(root))
    frontmatter, connessioni, body_inline = migration_state(root)
    print_json(
        {
            "total": total,
            "frontmatter": frontmatter,
            "connessioni": connessioni,
            "body_inline_links": body_inline,
        }
    )


def command_terms(args: argparse.Namespace) -> None:
    print_json(term_candidates(repo_root(), limit=args.limit))


def command_inventory(args: argparse.Namespace) -> None:
    print_json(asdict(run_inventory(repo_root())))


def command_facts(args: argparse.Namespace) -> None:
    print_json(asdict(run_facts(repo_root())))


def command_coverage(args: argparse.Namespace) -> None:
    print_json(asdict(run_coverage(repo_root())))


def command_fidelity(args: argparse.Namespace) -> None:
    print_json(asdict(run_fidelity(repo_root())))


def command_facets(args: argparse.Namespace) -> None:
    print_json(
        {
            "declared": {
                name: {"values": sorted(facet.values), "required": facet.required}
                for name, facet in {"ciclo": CYCLE_FACET, **EXTENDED_FACETS}.items()
            },
            "violations": [
                *facet_violations(repo_root()),
                *stage_cycle_state(repo_root())[1],
            ],
        }
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Utility per la knowledge base")
    sub = parser.add_subparsers(dest="command", required=True)

    audit = sub.add_parser("audit", help="audit completo della KB")
    audit.add_argument("--format", choices=["markdown", "json"], default="markdown")
    audit.set_defaults(func=command_audit)

    backlinks = sub.add_parser("backlinks", help="mostra link in/out di un nodo")
    backlinks.add_argument("node")
    backlinks.set_defaults(func=command_backlinks)

    orphans = sub.add_parser("orphans", help="lista nodi senza backlink")
    orphans.set_defaults(func=command_orphans)

    readme = sub.add_parser(
        "readme", help=f"verifica copertura del catalogo {CATALOG_NAME}"
    )
    readme.set_defaults(func=command_readme)

    migration = sub.add_parser("migration", help="verifica frontmatter/footer links")
    migration.set_defaults(func=command_migration)

    terms = sub.add_parser("terms", help="candidati a nuovi nodi da termini ricorrenti")
    terms.add_argument("--limit", type=int, default=12)
    terms.set_defaults(func=command_terms)

    inventory = sub.add_parser(
        "inventory", help="inventario host, profili e moduli derivato dal codice"
    )
    inventory.set_defaults(func=command_inventory)

    facts = sub.add_parser(
        "facts", help="confronta fatti documentati ad alta fiducia con il codice"
    )
    facts.set_defaults(func=command_facts)

    coverage = sub.add_parser(
        "coverage", help="segnala possibili scoperture documentali"
    )
    coverage.set_defaults(func=command_coverage)

    fidelity = sub.add_parser(
        "fidelity", help="aggrega i controlli anti-drift della KB"
    )
    fidelity.set_defaults(func=command_fidelity)

    facets = sub.add_parser(
        "facets", help="verifica gli attributi di dominio dichiarati (EXTENDED_FACETS)"
    )
    facets.set_defaults(func=command_facets)
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
