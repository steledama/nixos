import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest

spec = importlib.util.spec_from_file_location(
    "privacy", Path(__file__).resolve().parents[1] / "privacy.py"
)
privacy = importlib.util.module_from_spec(spec)
spec.loader.exec_module(privacy)


class PrivacyTests(unittest.TestCase):
    def test_checks_new_files_but_not_ignored_data_or_external_symlinks(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            (root / ".gitignore").write_text("private/\n")
            (root / "private").mkdir()
            (root / "private/data").write_text("private-customer")
            (root / "external").symlink_to(root / "private/data")
            (root / "new.md").write_text("line one\nPRIVATE-CUSTOMER\n")
            _, findings = privacy.scan(root, {"literals": ["private-customer"]})
            self.assertEqual(findings, ["new.md:2: regola privata 1"])
            self.assertNotIn("customer", " ".join(findings))

    def test_empty_rules_cannot_report_success(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(ValueError):
                privacy.scan(Path(directory), {"literals": []})
