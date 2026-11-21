"""Forma della direzione del plan, con compatibilità per gli adottanti."""

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import sources


class DirezioneTests(unittest.TestCase):
    def check(self, body):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "o1").mkdir()
            (root / "o1" / "plan.md").write_text(body, encoding="utf-8")
            return sources._check_direzione(root)

    def test_legacy_plan_is_accepted(self):
        self.assertEqual(self.check("# Plan\n\n## Task\n"), [])

    def test_direction_before_tasks_is_accepted(self):
        self.assertEqual(
            self.check("# Plan\n\n## Direzione\n\nVerso il traguardo.\n\n## Task\n"),
            [],
        )

    def test_empty_or_misplaced_direction_is_reported(self):
        self.assertTrue(self.check("# Plan\n\n## Direzione\n\n## Task\n"))
        self.assertTrue(self.check("# Plan\n\n## Task\n\n## Direzione\n\nTesto.\n"))


if __name__ == "__main__":
    unittest.main()
