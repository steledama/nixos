"""Profilo ripetibile del corpus KB; nessuna valutazione semantica."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import statistics
import subprocess
from collections import Counter
from pathlib import Path


def maturity(text: str, allowed: set[str]) -> tuple[str | None, list[str]]:
    """Legge il solo stato scalare nel frontmatter, non gli esempi nel corpo.

    Supporta il sottoinsieme usato dai nodi: valore semplice o quotato ed
    eventuale commento. Non pretende di essere un parser YAML generale.
    """
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        return None, ["frontmatter assente"]
    end = next((i for i in range(1, len(lines)) if lines[i] == "---"), None)
    if end is None:
        return None, ["frontmatter non chiuso"]
    entries = [line for line in lines[1:end] if re.match(r"^stato\s*:", line)]
    if len(entries) != 1:
        return None, ["stato assente" if not entries else "stato duplicato"]
    value = entries[0].split(":", 1)[1].strip()
    match = re.fullmatch(r"""(?:'([^']*)'|"([^"]*)"|([^\s#'"]+))(?:\s+#.*)?\s*""", value)
    if not match:
        return None, ["stato non scalare o sintassi non supportata"]
    state = next(group for group in match.groups() if group is not None)
    return state, [] if state in allowed else [f"stato fuori dominio: {state}"]


def node_files(root: Path) -> tuple[list[Path], list[str]]:
    kb = root / "kb"
    if not kb.is_dir() or kb.is_symlink():
        raise ValueError("kb/ deve essere una directory locale, non un symlink")
    included: list[Path] = []
    excluded: list[str] = []

    def fail_walk(error: OSError) -> None:
        raise error

    for directory, dirs, files in os.walk(kb, followlinks=False, onerror=fail_walk):
        base = Path(directory)
        for name in list(dirs):
            path = base / name
            if path.is_symlink() or name.startswith("."):
                excluded.append(path.relative_to(root).as_posix() + "/")
                dirs.remove(name)
        for name in files:
            path = base / name
            if path.suffix != ".md":
                continue
            if path.is_symlink() or name.startswith(".") or path == kb / "kb.md":
                excluded.append(path.relative_to(root).as_posix())
            else:
                included.append(path)
    return sorted(included), sorted(excluded)


def profile(root: Path, allowed: set[str]) -> dict:
    files, excluded = node_files(root)
    nodes = []
    for path in files:
        raw = path.read_bytes()
        text = raw.decode("utf-8")
        state, issues = maturity(text, allowed)
        nodes.append(
            {
                "path": path.relative_to(root).as_posix(),
                "sha256": hashlib.sha256(raw).hexdigest(),
                "lines": len(text.splitlines()),
                "bytes": len(raw),
                "state": state,
                "issues": issues,
            }
        )
    sizes = [node["lines"] for node in nodes]
    digest = hashlib.sha256(
        json.dumps(
            [(node["path"], node["sha256"]) for node in nodes],
            ensure_ascii=False,
            separators=(",", ":"),
        ).encode("utf-8")
    ).hexdigest()
    return {
        "scope": {
            "include": "kb/**/*.md (anche nodi non catalogati)",
            "exclude": "kb/kb.md, file/directory nascosti, symlink",
            "excluded_entries": excluded,
            "line_definition": "righe logiche incluse righe vuote e frontmatter",
            "state_domain": sorted(allowed),
        },
        "corpus_sha256": digest,
        "nodes_total": len(nodes),
        "lines": {
            "total": sum(sizes),
            "median": statistics.median(sizes) if sizes else None,
            "min": min(sizes) if sizes else None,
            "max": max(sizes) if sizes else None,
        },
        "maturity": {
            "counts": dict(sorted(Counter(n["state"] for n in nodes if not n["issues"]).items())),
            "valid": sum(not node["issues"] for node in nodes),
            "denominator": len(nodes),
            "invalid_nodes": [node["path"] for node in nodes if node["issues"]],
        },
        "manifest": nodes,
        "limits": [
            "Le impronte identificano il contenuto, non attestano la lettura.",
            "La maturità è dichiarata dall'autore, non misurata.",
            "Catalogo, rete, link e codice sono misurati da kb_tools locale.",
            "Nessuna verifica delle fonti, dei fatti o della copertura semantica.",
        ],
    }


def checkout(root: Path) -> dict:
    def git(*args: str) -> str | None:
        try:
            result = subprocess.run(
                ["git", "-C", str(root), *args],
                capture_output=True,
                text=True,
                check=False,
            )
        except OSError:
            return None
        return result.stdout.strip() if result.returncode == 0 else None

    return {
        "head": git("rev-parse", "HEAD"),
        "kb_changes": git("status", "--short", "--untracked-files=all", "--", "kb"),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, required=True, help="root del repository")
    parser.add_argument("--states", nargs="+", default=["bozza", "iniziale", "maturo"])
    args = parser.parse_args()
    root = args.root.resolve()
    try:
        result = profile(root, set(args.states))
    except (OSError, UnicodeError, ValueError) as error:
        parser.exit(2, f"Profilo non disponibile: {error}\n")
    result["checkout"] = checkout(root)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    raise SystemExit(1 if result["maturity"]["invalid_nodes"] else 0)


if __name__ == "__main__":
    main()
