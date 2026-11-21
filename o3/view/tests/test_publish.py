"""Pubblicazione delle viste: ultima vista buona, fonti pulite, richieste accodate.

Il builder è finto (copia `goal.md`): qui si prova la meccanica di `publish.py`,
non la resa. Eseguire con python3 -m unittest discover -s tests.
"""

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

BUILDERS = Path(__file__).resolve().parents[3] / "method" / ".." / "o3" / "view"
sys.path.insert(0, str(BUILDERS))

import publish


def git(repo: Path, *args: str) -> str:
    return subprocess.run(
        ["git", "-C", str(repo), "-c", "user.name=t", "-c", "user.email=t@t", *args],
        text=True,
        capture_output=True,
        check=True,
    ).stdout.strip()


def commit(repo: Path, text: str) -> str:
    (repo / "goal.md").write_text(text, encoding="utf-8")
    git(repo, "add", "-A")
    git(repo, "commit", "-qm", text)
    return git(repo, "rev-parse", "HEAD")


def fake_builder(source: Path, out: Path, sha: str, canon: str | None = None) -> None:
    text = (source / "goal.md").read_text(encoding="utf-8")
    out.mkdir(parents=True)
    (out / "index.html").write_text(text, encoding="utf-8")
    if "rotto" in text:
        raise RuntimeError("contratto violato")
    (out / "provenance.json").write_text(
        json.dumps({"commit": sha} | ({"canon": canon} if canon else {})),
        encoding="utf-8",
    )


def served(dest: Path) -> str:
    name = (dest / "current").read_text(encoding="utf-8").strip()
    return (dest / "releases" / name / "index.html").read_text(encoding="utf-8")


class PublishTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        base = Path(self.tmp.name)
        self.repo, self.dest = base / "repo", base / "pub"
        self.repo.mkdir()
        git(self.repo, "init", "-q")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def run_publish(self) -> int:
        return publish.publish(self.repo, self.dest, builder=fake_builder)

    def releases(self) -> list[str]:
        return sorted(path.name for path in (self.dest / "releases").iterdir())

    def test_pubblica_il_commit_non_il_working_tree(self) -> None:
        commit(self.repo, "uno")
        (self.repo / "goal.md").write_text("modifica locale", encoding="utf-8")
        (self.repo / "non-tracciato.md").write_text("x", encoding="utf-8")
        self.assertEqual(self.run_publish(), 0)
        self.assertEqual(served(self.dest), "uno")

    def test_errore_lascia_servita_la_versione_buona(self) -> None:
        commit(self.repo, "uno")
        self.run_publish()
        sha = commit(self.repo, "rotto")
        self.assertEqual(self.run_publish(), 1)
        self.assertEqual(served(self.dest), "uno")
        status = json.loads((self.dest / "status.json").read_text(encoding="utf-8"))
        self.assertFalse(status["ok"])
        self.assertEqual(status["requested"], sha)
        self.assertIn("contratto violato", status["error"])
        self.assertFalse(
            [name for name in self.releases() if name.endswith(".partial")]
        )

    def test_tiene_corrente_e_precedente(self) -> None:
        for text in ("uno", "due", "tre"):
            commit(self.repo, text)
            self.run_publish()
        self.assertEqual(served(self.dest), "tre")
        self.assertEqual(len(self.releases()), 2)

    def test_stesso_commit_non_ricostruisce(self) -> None:
        commit(self.repo, "uno")
        self.run_publish()
        before = self.releases()
        self.assertEqual(self.run_publish(), 0)
        self.assertEqual(self.releases(), before)

    def test_richiesta_durante_la_build_arriva_comunque(self) -> None:
        commit(self.repo, "uno")

        def builder_con_commit_concorrente(
            source: Path, out: Path, sha: str, canon: str | None = None
        ) -> None:
            fake_builder(source, out, sha, canon)
            if (source / "goal.md").read_text(encoding="utf-8") == "uno":
                commit(self.repo, "due")
                # La seconda pubblicazione trova il lock e si accoda.
                self.assertEqual(self.run_publish(), 0)

        publish.publish(self.repo, self.dest, builder=builder_con_commit_concorrente)
        self.assertEqual(served(self.dest), "due")
        self.assertFalse((self.dest / ".lock").exists())

    def test_interruzione_registrata_nello_stato(self) -> None:
        commit(self.repo, "uno")
        self.run_publish()
        sha = commit(self.repo, "due")

        def builder_interrotto(
            source: Path, out: Path, sha: str, canon: str | None = None
        ) -> None:
            out.mkdir(parents=True)
            raise SystemExit(143)

        with self.assertRaises(SystemExit):
            publish.publish(self.repo, self.dest, builder=builder_interrotto)
        status = json.loads((self.dest / "status.json").read_text(encoding="utf-8"))
        self.assertFalse(status["ok"])
        self.assertEqual(status["requested"], sha)
        self.assertEqual(status["error"], "pubblicazione interrotta")
        self.assertEqual(served(self.dest), "uno")
        self.assertFalse((self.dest / ".lock").exists())

    def test_lock_di_un_processo_morto_si_riprende(self) -> None:
        commit(self.repo, "uno")
        dead = subprocess.Popen([sys.executable, "-c", "pass"])
        dead.wait()
        (self.dest / "releases").mkdir(parents=True)
        (self.dest / ".lock").write_text(str(dead.pid), encoding="utf-8")
        self.assertEqual(self.run_publish(), 0)
        self.assertEqual(served(self.dest), "uno")

    def test_lock_di_un_processo_vivo_accoda(self) -> None:
        commit(self.repo, "uno")
        (self.dest / "releases").mkdir(parents=True)
        (self.dest / ".lock").write_text(str(os.getpid()), encoding="utf-8")
        self.assertEqual(self.run_publish(), 0)
        self.assertTrue((self.dest / ".pending").exists())
        self.assertIsNone(publish.current(self.dest))

    def test_commit_arrivato_durante_una_build_fallita_si_pubblica(self) -> None:
        commit(self.repo, "rotto")

        def builder_che_fallisce_e_vede_un_commit(
            source: Path, out: Path, sha: str, canon: str | None = None
        ) -> None:
            if (source / "goal.md").read_text(encoding="utf-8") == "rotto":
                commit(self.repo, "buono")
            fake_builder(source, out, sha, canon)

        self.assertEqual(
            publish.publish(
                self.repo, self.dest, builder=builder_che_fallisce_e_vede_un_commit
            ),
            0,
        )
        self.assertEqual(served(self.dest), "buono")


class ServeCheckTest(unittest.TestCase):
    def check(self, root: Path) -> int:
        return subprocess.run(
            [
                sys.executable,
                str(BUILDERS / "serve.py"),
                "--publish-root",
                str(root),
                "--check",
            ],
            capture_output=True,
            check=False,
        ).returncode

    def test_codici_di_uscita(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.assertEqual(self.check(root), 3)
            release = root / "releases" / "v1"
            release.mkdir(parents=True)
            (release / "index.html").write_text("ok", encoding="utf-8")
            (root / "current").write_text("v1\n", encoding="utf-8")
            self.assertEqual(self.check(root), 0)


if __name__ == "__main__":
    unittest.main()
