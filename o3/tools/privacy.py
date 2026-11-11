#!/usr/bin/env python3
"""Check publishable files against private rules, without printing matched data."""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess


def scan(root, config):
    rules = [
        re.compile(re.escape(s).encode(), re.IGNORECASE) for s in config["literals"]
    ]
    rules += [re.compile(s.encode(), re.IGNORECASE) for s in config.get("patterns", [])]
    if not rules:
        raise ValueError("Il controllo richiede almeno una regola privata")
    names = (
        subprocess.check_output(
            ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
            cwd=root,
        )
        .decode()
        .split("\0")
    )
    findings = []
    checked = 0
    for name in sorted(set(names) - {""}):
        path = root / name
        # Do not follow the method symlink or any other external dependency.
        if path.is_symlink():
            data = os.readlink(path).encode()
        elif path.is_file():
            data = path.read_bytes()
        else:
            continue
        checked += 1
        for number, rule in enumerate(rules, 1):
            match = rule.search(data)
            if match:
                line = data[: match.start()].count(b"\n") + 1
                findings.append(f"{name}:{line}: regola privata {number}")
    return checked, findings


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root", type=Path, default=Path(__file__).resolve().parents[2]
    )
    parser.add_argument(
        "--config",
        type=Path,
        default=Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
        / "nixos/privacy.json",
    )
    parser.add_argument("--if-configured", action="store_true")
    args = parser.parse_args()
    if not args.config.is_file():
        print("Privacy: regole private assenti, controllo non eseguito.")
        return 0 if args.if_configured else 2
    try:
        checked, findings = scan(args.root, json.loads(args.config.read_text()))
    except (ValueError, KeyError, OSError, subprocess.CalledProcessError):
        print(
            "Privacy: impossibile completare il controllo; verificare le regole locali."
        )
        return 2
    for finding in findings:
        print(finding)
    print(f"Privacy: {checked} file controllati, {len(findings)} riscontri.")
    return int(bool(findings))


if __name__ == "__main__":
    raise SystemExit(main())
