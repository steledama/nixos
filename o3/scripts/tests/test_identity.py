"""Local identity must be explicit and must never change the public lock."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "con-identita.sh"


class IdentityTests(unittest.TestCase):
    def test_missing_identity_does_not_run_command(self):
        with tempfile.TemporaryDirectory() as directory:
            env = os.environ | {"NIXOS_IDENTITY_DIR": directory + "/missing"}
            result = subprocess.run(
                [str(SCRIPT), "nix", "eval", ".#test"], env=env, capture_output=True
            )
            self.assertEqual(result.returncode, 2)
            self.assertIn(b"Identit", result.stderr)

    def test_arguments_keep_spaces_and_prevent_lock_write(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            identity = root / "private identity"
            identity.mkdir()
            (identity / "default.nix").write_text("{}")
            command = root / "nix"
            command.write_text('#!/bin/sh\nprintf "%s\\n" "$@"\n')
            command.chmod(0o755)
            env = os.environ | {
                "NIXOS_IDENTITY_DIR": str(identity),
                "PATH": f"{root}:{os.environ['PATH']}",
            }
            result = subprocess.run(
                [str(SCRIPT), "nix", "eval", ".#test"],
                env=env,
                capture_output=True,
                text=True,
            )
            self.assertEqual(result.returncode, 0)
            self.assertEqual(
                result.stdout.splitlines(),
                [
                    "eval",
                    ".#test",
                    "--override-input",
                    "identity",
                    f"path:{identity}",
                    "--no-write-lock-file",
                ],
            )


if __name__ == "__main__":
    unittest.main()
