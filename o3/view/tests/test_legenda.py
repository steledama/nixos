"""Contratto della legenda del plan: indici `w`/`p` di `Dip.` contro le chiose."""

import sys
import tempfile
import unittest
from pathlib import Path

BUILDERS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BUILDERS))

import sources

TABELLA = """# Plan

| Ciclo | Ob. | Task | Dip. |
| ----- | --- | ---- | ---- |
| dev | 1 | Primo | w1 |
| dev | 1 | Secondo | p2, #1 |
| dev | 1 | Terzo | — |

"""


class LegendaTests(unittest.TestCase):
    def errori(self, legenda):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "o1").mkdir()
            (root / "o1" / "plan.md").write_text(TABELLA + legenda, encoding="utf-8")
            return sources._check_legenda(root, sources.parse_plan(root))

    def test_spellings_in_use_are_read(self):
        self.assertEqual(self.errori("- `w1` — causa\n- p2 → pausa\n"), [])
        self.assertEqual(self.errori("- **w1 · Primo** — causa\n- p2! — pausa\n"), [])

    def test_gloss_without_row_is_an_orphan(self):
        errori = self.errori("- w1 — causa\n- p2 — pausa\n- w3 — task chiuso\n")
        self.assertEqual(len(errori), 1)
        self.assertIn("w3 senza riga", errori[0])

    def test_index_without_gloss_is_reported(self):
        errori = self.errori("- w1 — causa\n")
        self.assertEqual(len(errori), 1)
        self.assertIn("p2 in Dip. di «Secondo» senza chiosa", errori[0])


if __name__ == "__main__":
    unittest.main()
