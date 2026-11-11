"""Contratto osservabile del calendario, senza rete né modifiche al registro."""

import csv
import io
import json
import os
import subprocess
import tempfile
import unittest
from datetime import date, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / "o3/scripts/maintenance-due.sh"


class MaintenanceDueTests(unittest.TestCase):
    def run_due(self, data, now="2026-10-20 12:00", host="deck", plan=None):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "i1").mkdir()
            (root / "o1").mkdir()
            if data is not None:
                (root / "i1/manutenzione.json").write_text(json.dumps(data))
            (root / "o1/plan.md").write_text(plan or "")
            result = subprocess.run(
                [str(SCRIPT), host],
                env={
                    **os.environ,
                    "FLAKE_DIR": directory,
                    "MAINTENANCE_NOW": now,
                    "TZ": "Europe/Rome",
                    "MAINTENANCE_LOG": str(root / "i1/manutenzione.json"),
                },
                check=False,
                capture_output=True,
                text=True,
            )
            if data is not None:
                self.assertEqual(
                    json.loads((root / "i1/manutenzione.json").read_text()), data
                )
            return result

    def rows(self, data, **kwargs):
        result = self.run_due(data, **kwargs)
        self.assertEqual(result.returncode, 0, result.stderr)
        return {
            r["percorso"]: r
            for r in csv.DictReader(io.StringIO(result.stdout), delimiter="\t")
        }

    def test_current_register_all_hosts(self):
        data = json.loads((ROOT / "i1/manutenzione.json").read_text())
        plan = (ROOT / "o1/plan.md").read_text()
        # Il registro è vivo: si verifica il formato, senza congelarne gli esiti.
        dates = []

        def collect(value):
            if isinstance(value, dict):
                if "data" in value:
                    dates.append(date.fromisoformat(value["data"]))
                for child in value.values():
                    collect(child)

        collect(data)
        now = str(max(dates) + timedelta(days=1)) + " 12:00"
        for host in ("deck", "neve", "game"):
            with self.subTest(host=host):
                rows = self.rows(data, host=host, plan=plan, now=now)
                self.assertEqual(rows["ia"]["applicabile"], "sì")
                self.assertEqual(
                    rows["casa.gogcli"]["cadenza_giorni"],
                    str(data["casa"]["cadenza_giorni"]),
                )

    def test_missing_log_and_new_world_task(self):
        plan = (
            "| runtime | 1 | Nuovo task | w7 |\n\n"
            "- `w7` — upstream: una issue. probe: github a/b#1\n  closed\n"
        )
        rows = self.rows(None, plan=plan)
        self.assertEqual(rows["ia"]["stato"], "mai controllato")
        self.assertEqual(rows["world.Nuovo task"]["stato"], "mai controllato")
        self.assertEqual(rows["casa.gogcli"]["stato"], "mai controllato")

    def test_world_only_with_probe(self):
        plan = (
            "| runtime | 1 | Con sonda | w1! |\n"
            "| runtime | 1 | Ad arrivo | w2 |\n"
            "| runtime | 1 | Pausa | p1 |\n"
            "| runtime | 1 | Senza legenda | w3 |\n\n"
            "- `w1!` — upstream. probe: nixpkgs x >= 1\n"
            "- `w2` — custode. arrival: una email, via Gmail\n"
            "- `p1` — nostra. probe: per errore su una pausa\n"
        )
        world = {k for k in self.rows({}, plan=plan) if k.startswith("world.")}
        self.assertEqual(world, {"world.Con sonda"})

    def test_midnight_calendar_and_debounce_boundary(self):
        data = {
            "ia": {
                "data": "2026-10-19",
                "ora": "23:59",
                "cadenza_giorni": 1,
                "applicato_su": ["neve"],
            }
        }
        row = self.rows(data, now="2026-10-20 00:05")["ia"]
        self.assertEqual(
            (row["giorni"], row["stato"], row["applicato_su"]),
            ("1", "debounce", "assente"),
        )
        self.assertEqual(
            self.rows(data, now="2026-10-20 00:09")["ia"]["stato"], "dovuto"
        )

    def test_calendar_across_dst(self):
        data = {"ia": {"data": "2026-03-29", "cadenza_giorni": 1}}
        row = self.rows(data, now="2026-03-30 00:05")["ia"]
        self.assertEqual((row["giorni"], row["stato"]), ("1", "dovuto"))

    def test_inherited_cadence_and_independent_child(self):
        data = {
            "casa": {
                "data": "2026-10-19",
                "cadenza_giorni": 7,
                "gogcli": {"data": "2026-10-12"},
            },
        }
        rows = self.rows(data, host="deck")
        self.assertEqual(rows["casa"]["stato"], "non dovuto")
        self.assertEqual(rows["casa.gogcli"]["stato"], "dovuto")
        self.assertEqual(rows["casa.gogcli"]["freschezza"], "in ritardo")

    def test_revisions_not_calendar_and_removed_world_excluded(self):
        data = {
            "casa": {
                "nixpkgs_rev": "abc",
                "host_specifico": {
                    "neve": {
                        "pacchetti_host": {
                            "data": "2000-01-01",
                            "nixpkgs_rev_valutato": "abc",
                        }
                    }
                },
            },
            "world": {"Rimosso": {"data": "2000-01-01", "cadenza_giorni": 30}},
        }
        rows = self.rows(data, host="neve")
        self.assertEqual(
            rows["casa.host_specifico.neve.pacchetti_host"]["stato"], "non dovuto"
        )
        self.assertNotIn("world.Rimosso", rows)
        self.assertEqual(rows["orfano.world.Rimosso"]["stato"], "voce orfana")
        self.assertEqual(rows["orfano.world.Rimosso"]["data"], "2000-01-01")

    def test_orphans_only_when_task_left_plan(self):
        plan = (
            "| Ciclo | Ob. | Task | Dip. |\n"
            "| ----- | --- | ---- | ---- |\n"
            "| runtime | 1 | Vivo | w1 |\n"
            "| runtime | 1 | Promosso vivo | — |\n\n"
            "- `w1` — upstream. probe: github a/b#1 closed\n"
        )
        data = {
            "casa": {"promosso": "Promosso vivo"},
            "ia": {"promosso": "Chiuso"},
            "world": {
                "Vivo": {"data": "2026-10-19", "cadenza_giorni": 30},
                "Chiuso": {"data": "2026-10-19", "cadenza_giorni": 30},
            },
        }
        orphans = {
            k: r["stato"]
            for k, r in self.rows(data, plan=plan).items()
            if k.startswith("orfano.")
        }
        self.assertEqual(
            orphans,
            {
                "orfano.world.Chiuso": "voce orfana",
                "orfano.ia.promosso": "promosso orfano",
            },
        )

    def test_bad_data_fails(self):
        for data in (
            [],
            {"ia": {"data": "2026-10-19"}},
            {"ia": {"data": "2026-10-21", "cadenza_giorni": 1}},
            {"ia": {"data": "2026-02-30", "cadenza_giorni": 1}},
        ):
            with self.subTest(data=data):
                self.assertNotEqual(self.run_due(data).returncode, 0)
        self.assertNotEqual(self.run_due({}, host="ignoto").returncode, 0)


if __name__ == "__main__":
    unittest.main()
