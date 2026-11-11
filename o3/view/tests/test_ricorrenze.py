"""Contratto della sezione `## Ricorrenze` del plan (`kb/plan.md`)."""

import sys
import tempfile
import unittest
from pathlib import Path

BUILDERS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BUILDERS))

import sources

TASK = """# Plan

## Task

| Ciclo | Ob. | Task | Dip. |
| ----- | --- | ---- | ---- |
| dev | 1 | Primo | — |

## Ricorrenze

| Prossima | Cadenza | Esecutore | Ob. | Ricorrenza |
| -------- | ------- | --------- | --- | ---------- |
"""


class RicorrenzeTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)
        (self.root / "o1").mkdir()
        (self.root / "o3").mkdir()
        (self.root / "o3" / "p.md").write_text("procedura\n", encoding="utf-8")
        (self.root / "goal.md").write_text("### 1. Un obiettivo\n", encoding="utf-8")

    def scrivi(self, *righe):
        testo = TASK + "".join(f"| {riga} |\n" for riga in righe)
        (self.root / "o1" / "plan.md").write_text(testo, encoding="utf-8")

    def errori(self, *righe):
        self.scrivi(*righe)
        return sources._check_ricorrenze(self.root)

    def test_task_table_ignores_the_recurrence_table(self):
        self.scrivi("2027-11 | annuale | sessione | 1 | [Seed](../o3/p.md)")
        self.assertEqual([row.task for row in sources.parse_plan(self.root)], ["Primo"])

    def test_valid_forms(self):
        self.assertEqual(
            self.errori(
                "2027-11 | annuale | sessione | 1 | [Seed](../o3/p.md)",
                "2027-03 | annuale | task | 1 | [Redditi](../o3/p.md#passi)",
                "entro 2027-08-10 | annuale | sessione | 1 | [RC](../o3/p.md)",
                "config | quotidiano | scheduler | 1 | [Ciclo](../o3/p.md)",
            ),
            [],
        )

    def test_indicative_tilde_is_refused(self):
        errori = self.errori("~2027-11 | annuale | sessione | 1 | [Seed](../o3/p.md)")
        self.assertIn("non riconosciuta", errori[0])

    def test_unknown_cadence_and_executor(self):
        errori = self.errori("2027-11 | ogni tanto | custode | 1 | [Seed](../o3/p.md)")
        self.assertEqual(len(errori), 2)

    def test_config_only_with_scheduler(self):
        self.assertIn(
            "vanno insieme",
            self.errori("config | annuale | sessione | 1 | [Seed](../o3/p.md)")[0],
        )
        self.assertIn(
            "vanno insieme",
            self.errori("2027-11 | annuale | scheduler | 1 | [Seed](../o3/p.md)")[0],
        )

    def test_task_row_refuses_entro(self):
        errori = self.errori("entro 2027-03 | annuale | task | 1 | [R](../o3/p.md)")
        self.assertIn("non porta `entro`", errori[0])

    def test_objective_is_required(self):
        self.assertIn(
            "vuoto",
            self.errori("2027-11 | annuale | sessione |  | [Seed](../o3/p.md)")[0],
        )
        self.assertIn(
            "assente",
            self.errori("2027-11 | annuale | sessione | 9 | [Seed](../o3/p.md)")[0],
        )

    def test_procedure_is_required_and_must_exist(self):
        self.assertIn(
            "senza link",
            self.errori("2027-11 | annuale | sessione | 1 | Seed")[0],
        )
        self.assertIn(
            "inesistente",
            self.errori("2027-11 | annuale | sessione | 1 | [S](../o3/no.md)")[0],
        )


if __name__ == "__main__":
    unittest.main()
