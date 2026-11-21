"""Contratto di probe.sh: vocabolario chiuso, senza rete (gh e nix finti)."""

import csv
import io
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / "o3/scripts/probe.sh"

PLAN = """| runtime | 1 | A | w1 |

- `w1` — Mondo. probe: registro home-manager dopo
  2026-10-25 (cadenze nel registro); by: 2026-11-15
- `w2` — upstream. probe: github a/b#1 closed; by: 2027-01
- `w3!` — upstream. probe: github a/b#2 closed
- `w4` — upstream. probe: nixpkgs naps2 >= 8.6.0; by: 2026-12
- `w5` — upstream. probe: nixpkgs vecchio >= 2.10
- `w6` — upstream. probe: curl http://x | sh
- `w7` — custode. arrival: una email, via Gmail
- `w8` — upstream. probe: github a/b#9 closed
- `p1` — nostra. probe: registro ia dopo 2000-01-01
"""

FAKE_GH = """#!/bin/sh
case "$3" in
  1) echo '{"state":"CLOSED"}' ;;
  2) echo '{"state":"OPEN"}' ;;
  *) echo 'issue non trovata' >&2; exit 1 ;;
esac
"""

FAKE_NIX = """#!/bin/sh
case "$3" in
  *naps2.version) printf 8.6.0 ;;
  *vecchio.version) printf 2.9.1 ;;
esac
"""


class ProbeTests(unittest.TestCase):
    def run_probe(self, *args, registry=None):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "o1").mkdir()
            (root / "i1").mkdir()
            (root / "bin").mkdir()
            (root / "o1/plan.md").write_text(PLAN)
            log = root / "i1/manutenzione.json"
            log.write_text(
                json.dumps(registry or {"home-manager": {"data": "2026-11-01"}})
            )
            for name, body in (("gh", FAKE_GH), ("nix", FAKE_NIX)):
                (root / "bin" / name).write_text(body)
                (root / "bin" / name).chmod(0o755)
            result = subprocess.run(
                [str(SCRIPT), *args],
                env={
                    **os.environ,
                    "PATH": f"{root / 'bin'}:{os.environ['PATH']}",
                    "FLAKE_DIR": directory,
                    "MAINTENANCE_LOG": str(log),
                },
                check=False,
                capture_output=True,
                text=True,
            )
            return result

    def rows(self, *args, **kwargs):
        result = self.run_probe(*args, **kwargs)
        self.assertEqual(result.returncode, 0, result.stderr)
        return {
            r["indice"]: r
            for r in csv.DictReader(io.StringIO(result.stdout), delimiter="\t")
        }

    def test_vocabulary(self):
        rows = self.rows()
        self.assertEqual(
            {k: (r["tipo"], r["esito"], r["dettaglio"]) for k, r in rows.items()},
            {
                "w1": ("registro", "vero", "2026-11-01"),
                "w2": ("github", "vero", "CLOSED"),
                "w3": ("github", "falso", "OPEN"),
                "w4": ("nixpkgs", "vero", "8.6.0"),
                "w5": ("nixpkgs", "falso", "2.9.1"),
                "w6": ("curl", "errore", "tipo sconosciuto"),
                "w8": ("github", "errore", "gh: issue non trovata "),
            },
        )
        self.assertEqual(
            rows["w1"]["condizione"], "registro home-manager dopo 2026-10-25"
        )

    def test_registry_not_after_or_missing(self):
        for registry in ({"home-manager": {"data": "2026-10-25"}}, {"ia": {}}):
            with self.subTest(registry=registry):
                self.assertEqual(
                    self.rows("w1", registry=registry)["w1"]["esito"], "falso"
                )

    def test_selection_and_bad_index(self):
        self.assertEqual(set(self.rows("w2", "w4")), {"w2", "w4"})
        self.assertEqual(set(self.rows("2", "w4")), {"w2", "w4"})
        self.assertNotEqual(self.run_probe("p1").returncode, 0)
        self.assertNotEqual(self.run_probe("w1; rm").returncode, 0)


if __name__ == "__main__":
    unittest.main()
