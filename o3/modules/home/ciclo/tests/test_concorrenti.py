"""Hook reale con transcript sintetici: risposta all'avvio e nuove chiamate."""

import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest
from datetime import datetime, timezone

SCRIPT = Path(__file__).resolve().parents[1] / "ciclo-concorrenti.sh"


class Concorrenti(unittest.TestCase):
    def run_hook(
        self, family, kind, offset=10, command="git commit -m prova", other=False
    ):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            repo = root / "repo"
            repo.mkdir()
            subprocess.run(["git", "init", "-q", str(repo)], check=True)
            state = root / "state"
            state.mkdir()
            marker = state / "inizio-giro"
            marker.touch()
            start = marker.stat().st_mtime - 60
            os.utime(marker, (start, start))

            def event(seconds, item):
                timestamp = datetime.fromtimestamp(
                    start + seconds, timezone.utc
                ).isoformat()
                if family == "claude":
                    return {
                        "type": "assistant",
                        "timestamp": timestamp,
                        "message": {"content": [{"type": item}]},
                    }
                return {
                    "type": "response_item",
                    "timestamp": timestamp,
                    "payload": {"type": item},
                }

            cwd = str(root / "altro" if other else repo)
            if family == "claude":
                encoded = re.sub(r"[^a-zA-Z0-9]", "-", str(repo))
                file = root / ".claude" / "projects" / encoded / "s.jsonl"
                meta = {"cwd": cwd}
            else:
                file = root / ".codex" / "sessions" / "rollout-s.jsonl"
                meta = {"type": "session_meta", "payload": {"cwd": cwd}}
            file.parent.mkdir(parents=True)
            old = "tool_use" if family == "claude" else "function_call"
            file.write_text(
                "\n".join(map(json.dumps, [meta, event(-10, old), event(offset, kind)]))
                + "\n{partial"
            )
            result = subprocess.run(
                ["bash", "-euo", "pipefail", str(SCRIPT)],
                cwd=repo,
                input=json.dumps({"tool_input": {"command": command}}),
                text=True,
                capture_output=True,
                env={
                    **os.environ,
                    "HOME": tmp,
                    "CODEX_HOME": str(root / ".codex"),
                    "STATE_DIRECTORY": str(state),
                    "CLAUDE_PROJECT_DIR": str(repo),
                },
            )
            blocked = (state / "concorrenti.json").exists()
            self.assertEqual(blocked, result.returncode == 2, result.stderr)
            return result.returncode

    def test_launcher_reply_does_not_block(self):
        self.assertEqual(self.run_hook("claude", "text"), 0)
        self.assertEqual(self.run_hook("codex", "message"), 0)

    def test_calls_block(self):
        for family, kind in [
            ("claude", "tool_use"),
            ("codex", "function_call"),
            ("codex", "custom_tool_call"),
            ("codex", "local_shell_call"),
        ]:
            with self.subTest(kind=kind):
                self.assertEqual(self.run_hook(family, kind), 2)

    def test_old_calls_and_outputs_do_not_block(self):
        self.assertEqual(self.run_hook("claude", "tool_use", offset=-1), 0)
        self.assertEqual(self.run_hook("codex", "function_call_output"), 0)

    def test_other_repo_does_not_block(self):
        self.assertEqual(self.run_hook("codex", "function_call", other=True), 0)

    def test_non_commit_does_not_block(self):
        self.assertEqual(
            self.run_hook("codex", "function_call", command="git status"), 0
        )
