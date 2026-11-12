"""Controlli NixOS per il nucleo KB canonico: fonti dichiarative e livelli."""

import re
from collections import Counter
from dataclasses import asdict, dataclass
from pathlib import Path

NIX_PATH_RE = re.compile(r"(?<![\w.-])(\.{1,2}/[A-Za-z0-9_./-]+\.nix)")


FLAKE_HOST_RE = re.compile(
    r'^\s+([a-z0-9-]+)\s*=\s*mkHost\s+(?:[\w.-]+\s+)?"[^"]+";', re.MULTILINE
)


FLAKE_HOME_RE = re.compile(r'^\s+"([^"]+)"\s*=\s*mkHome\s+\{', re.MULTILINE)


TABLE_FIRST_CELL_RE = re.compile(r"^\|\s*([^|]+?)\s*\|", re.MULTILINE)


PROJECT_MAP_PROFILE_RE = re.compile(r"`([^`]+@[^`]+)`")


BOLD_LIST_ITEM_RE = re.compile(r"^- \*\*`?([^*`]+)`?\*\*", re.MULTILINE)


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


DUAL_LEVEL_ALLOWED = {"fish", "ssh"}


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


def kb_files(root: Path) -> list[Path]:
    # Esclude l'indice di collezione omonimo (kb/kb.md): è il catalogo, non un nodo.
    return sorted(p for p in (root / "kb").glob("*.md") if p.name != "kb.md")


def nix_files(root: Path) -> list[Path]:
    folders = [root / "o3" / "hosts", root / "o3" / "home", root / "o3" / "modules"]
    return sorted(path for folder in folders for path in folder.rglob("*.nix"))


def module_files(root: Path) -> list[Path]:
    return sorted((root / "o3" / "modules").rglob("*.nix"))


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


COMMANDS = {
    "inventory": lambda root, core: asdict(run_inventory(root)),
    "facts": lambda root, core: asdict(run_facts(root)),
    "coverage": lambda root, core: asdict(run_coverage(root)),
    "fidelity": lambda root, core: asdict(run_fidelity(root)),
}


def audit(root, core):
    return {"CROSS-FOLDER": cross_folder_links(root)}
