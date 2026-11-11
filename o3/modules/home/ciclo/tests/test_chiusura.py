"""Regressioni della chiusura, eseguendo lo script reale con tracce isolate."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "ciclo-chiusura.sh"


class Chiusura(unittest.TestCase):
    def close(
        self, result="success", code="exited", status="0", rc=0, event=True, reason=None
    ):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            subprocess.run(["git", "init", "-q", tmp], check=True)
            cfg = root / "config.json"
            cfg.write_text('{"repo": "prova"}')
            stream = root / "giro.jsonl"
            stream.write_text(
                json.dumps({"type": "result", "is_error": False})
                if event
                else '{"type": "assistant"}\n'
            )
            current = {"id": "prova", "giro": str(stream)}
            if rc is not None:
                current["claude_exit"] = rc
            if reason:
                current["motivo"] = reason
            (root / "corrente.json").write_text(json.dumps(current))
            subprocess.run(
                ["bash", "-euo", "pipefail", str(SCRIPT), str(cfg)],
                cwd=root,
                check=True,
                capture_output=True,
                env={
                    **os.environ,
                    "STATE_DIRECTORY": tmp,
                    "INVOCATION_ID": "prova",
                    "SERVICE_RESULT": result,
                    "EXIT_CODE": code,
                    "EXIT_STATUS": status,
                },
            )
            return json.loads((root / "ultimo.json").read_text())

    def test_completed(self):
        self.assertEqual(self.close()["esito"], "riuscito")

    def test_manual_stop(self):
        row = self.close(code="killed", status="TERM", rc=None, event=False)
        self.assertEqual((row["esito"], row["motivo"]), ("arresto", "interrotto"))
        self.assertIsNone(row["claude_exit"])

    def test_stop_after_final_event(self):
        self.assertEqual(self.close(code="killed", status="TERM")["esito"], "arresto")

    def test_missing_confirmation(self):
        for opts in ({"event": False}, {"rc": None}):
            with self.subTest(opts=opts):
                self.assertEqual(self.close(**opts)["motivo"], "interrotto")

    def test_timeout(self):
        self.assertEqual(
            self.close(result="timeout", rc=None, event=False)["esito"], "timeout"
        )

    def test_explicit_stop(self):
        row = self.close(result="exit-code", status="15", reason="sessione-concorrente")
        self.assertEqual(
            (row["esito"], row["motivo"]), ("arresto", "sessione-concorrente")
        )

    def test_error(self):
        self.assertEqual(
            self.close(result="signal", code="killed", status="KILL")["esito"], "errore"
        )
