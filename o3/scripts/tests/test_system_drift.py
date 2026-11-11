"""Contratto di system-drift.sh: provenienza dalla revisione attiva e verdetto
dal confronto col toplevel attivo, identità locale compresa (nix finto, repo
git temporaneo, senza rete)."""

import hashlib
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCRIPTS = ("system-drift.sh", "con-identita.sh")
CONFIG = "o3/hosts/game/sistema.txt"

# nix finto: narHash dal commit, toplevel da configurazione del commit,
# identità e revisione forzata. Gli altri comandi falliscono.
FAKE_NIX = r"""#!/usr/bin/env python3
import hashlib, json, re, subprocess, sys
args = sys.argv[1:]
def rev_of(ref):
    return re.search(r"\?rev=([0-9a-f]{40})", ref).group(1)
def repo_of(ref):
    return re.match(r"git\+file://([^?]+)", ref).group(1)
if args[:2] == ["flake", "metadata"]:
    print(json.dumps({"locked": {"narHash": "sha256-" + rev_of(args[3])[:20] + "="}}))
    sys.exit(0)
if args[0] == "eval":
    ref = args[2]
    config = subprocess.run(["git", "-C", repo_of(ref), "show", rev_of(ref) + ":CONFIG"],
                            capture_output=True, text=True, check=True).stdout
    identity_dir = args[args.index("--override-input") + 2].removeprefix("path:")
    identity = open(identity_dir + "/default.nix").read()
    expr = args[args.index("--apply") + 1]
    forced = re.search(r'mkForce "([^"]*)"', expr).group(1)
    kind = expr.rsplit(".", 1)[1]
    digest = hashlib.sha256((config + identity + forced + kind).encode()).hexdigest()
    print(f"/nix/store/{digest[:32]}-nixos-system-game", end="")
    sys.exit(0)
sys.exit(1)
""".replace("CONFIG", CONFIG)


def toplevel(config, identity, revision, kind="outPath"):
    digest = hashlib.sha256((config + identity + revision + kind).encode()).hexdigest()
    return f"/nix/store/{digest[:32]}-nixos-system-game"


class SystemDriftTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        root = Path(self.tmp.name)
        self.repo = root / "repo"
        (self.repo / "o3/scripts").mkdir(parents=True)
        (self.repo / "o3/hosts/game").mkdir(parents=True)
        for name in SCRIPTS:
            shutil.copy(ROOT / "o3/scripts" / name, self.repo / "o3/scripts" / name)
        (self.repo / "flake.lock").write_text('{"nodes": {}}')
        self.identity = root / "identity"
        self.identity.mkdir()
        (self.identity / "default.nix").write_text("{ reale = true; }")
        self.other_identity = root / "altra"
        self.other_identity.mkdir()
        (self.other_identity / "default.nix").write_text("{ template = true; }")
        bin_dir = root / "bin"
        bin_dir.mkdir()
        (bin_dir / "nix").write_text(FAKE_NIX)
        (bin_dir / "nix").chmod(0o755)
        self.env = os.environ | {
            "PATH": f"{bin_dir}:{os.environ['PATH']}",
            "NIXOS_IDENTITY_DIR": str(self.identity),
            "GIT_AUTHOR_NAME": "t",
            "GIT_AUTHOR_EMAIL": "t@invalid",
            "GIT_COMMITTER_NAME": "t",
            "GIT_COMMITTER_EMAIL": "t@invalid",
        }
        self.git("init", "-q")
        self.base = self.commit("sistema A", "base")

    def tearDown(self):
        self.tmp.cleanup()

    def git(self, *args):
        return subprocess.run(
            ["git", "-C", str(self.repo), *args],
            env=self.env,
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()

    def commit(self, config, message, path=CONFIG):
        (self.repo / path).parent.mkdir(parents=True, exist_ok=True)
        (self.repo / path).write_text(config)
        self.git("add", "-A")
        self.git("commit", "-q", "-m", message)
        return self.git("rev-parse", "HEAD")

    def drift(self, *args, env=None):
        result = subprocess.run(
            [str(self.repo / "o3/scripts/system-drift.sh"), "game", *args],
            env=env or self.env,
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout

    def nar(self, rev):
        return "nar:sha256-" + rev[:20] + "="

    def identity_text(self, directory=None):
        return ((directory or self.identity) / "default.nix").read_text()

    def test_build_pulito_con_identita_allineato(self):
        rev = self.nar(self.base)
        out = self.drift(rev, toplevel("sistema A", self.identity_text(), rev))
        self.assertIn(f"provenienza: commit {self.base[:7]}", out)
        self.assertIn("verdetto: allineato\n", out)

    def test_revisione_precedente_commit_di_soli_testi(self):
        rev = self.nar(self.base)
        self.commit("nota", "docs", path="kb/nota.md")
        out = self.drift(rev, toplevel("sistema A", self.identity_text(), rev))
        self.assertIn("verdetto: allineato (commit successivi senza effetto", out)

    def test_revisione_precedente_sistema_cambiato(self):
        rev = self.nar(self.base)
        self.commit("sistema B", "cambia il sistema")
        out = self.drift(rev, toplevel("sistema A", self.identity_text(), rev))
        self.assertIn("verdetto: deriva (rebuild pendente)", out)
        self.assertIn("cambia il sistema", out)

    def test_albero_modificato(self):
        rev = self.git("rev-parse", "HEAD") + "-dirty"
        out = self.drift(rev, toplevel("sistema locale", self.identity_text(), rev))
        self.assertIn("provenienza: albero modificato", out)
        self.assertIn(
            "verdetto: deriva (sistema costruito da un albero modificato", out
        )
        self.assertIn("nessuno (stesso commit di HEAD)", out)

    def test_albero_modificato_senza_effetto(self):
        rev = self.git("rev-parse", "HEAD") + "-dirty"
        out = self.drift(rev, toplevel("sistema A", self.identity_text(), rev))
        self.assertIn(
            "verdetto: allineato (il sistema coincide con HEAD; provenienza modificata)",
            out,
        )

    def test_narhash_di_nessun_commit(self):
        rev = "nar:sha256-" + "f" * 20 + "="
        out = self.drift(rev, toplevel("sistema locale", self.identity_text(), rev))
        self.assertIn("narHash di nessuno degli ultimi", out)
        self.assertIn(
            "verdetto: deriva (sistema costruito da un albero modificato", out
        )

    def test_identita_diversa_non_e_allineamento(self):
        rev = self.nar(self.base)
        sistema = toplevel("sistema A", self.identity_text(self.other_identity), rev)
        out = self.drift(rev, sistema)
        self.assertNotIn("verdetto: allineato", out)
        self.assertIn("identità locale o input cambiati", out)

    def test_identita_assente(self):
        rev = self.nar(self.base)
        env = self.env | {"NIXOS_IDENTITY_DIR": str(self.repo / "assente")}
        out = self.drift(rev, toplevel("sistema A", self.identity_text(), rev), env=env)
        self.assertIn("verdetto: non misurabile (valutazione di HEAD fallita", out)

    def test_build_precedente_dirty_confrontato_con_head(self):
        out = self.drift("dirty", toplevel("sistema A", self.identity_text(), "dirty"))
        self.assertIn("provenienza: sconosciuta", out)
        self.assertIn(
            "verdetto: allineato (il sistema coincide con HEAD; provenienza sconosciuta)",
            out,
        )
        out = self.drift(
            "dirty", toplevel("sistema vecchio", self.identity_text(), "dirty")
        )
        self.assertIn("verdetto: deriva (provenienza sconosciuta", out)

    def test_senza_toplevel_confronto_dei_drv(self):
        self.commit("nota", "docs", path="kb/nota.md")
        out = self.drift(self.nar(self.base))
        self.assertIn("identità locale non è confrontata", out)
        self.assertIn("verdetto: allineato (commit successivi senza effetto", out)
        self.assertIn("non misurabile", self.drift("dirty"))

    def test_forme_estranee_rifiutate(self):
        sistema = toplevel("sistema A", self.identity_text(), "x")
        self.assertIn(
            "non misurabile (revisione in forma sconosciuta)",
            self.drift('x"; builtins.abort "y', sistema),
        )
        self.assertIn(
            "non misurabile (toplevel attivo in forma sconosciuta)",
            self.drift(self.nar(self.base), "/tmp/sistema"),
        )


if __name__ == "__main__":
    unittest.main()
