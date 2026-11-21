"""Contratto di seed-identita.sh contro una cassaforte finta, senza bw reale."""

import json
import os
import subprocess
import tempfile
import textwrap
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / "o3/scripts/seed-identita.sh"
NOMI = ["default.nix", "home.nix", "work.nix"]
SEGRETO = "valore-riservato"

# bw finto: le voci stanno in un JSON; registra le chiamate a lock e edit.
FAKE_BW = textwrap.dedent(
    """\
    #!/usr/bin/env python3
    import base64, json, os, sys
    store = os.environ["FAKE_BW_STORE"]
    data = json.load(open(store))
    args = sys.argv[1:]
    def save():
        json.dump(data, open(store, "w"))
    if args[:2] == ["unlock", "--raw"]:
        data["unlock"] += 1; save(); print("sessione")
    elif args[0] in ("sync", "lock"):
        data[args[0]] += 1; save()
    elif args[:2] == ["list", "items"]:
        term = args[3]
        print(json.dumps([i for i in data["items"] if term in i["name"]]))
    elif args[:2] == ["get", "item"]:
        print(json.dumps(next(i for i in data["items"] if i["id"] == args[2])))
    elif args[0] == "encode":
        sys.stdout.write(base64.b64encode(sys.stdin.read().encode()).decode())
    elif args[:2] == ["edit", "item"]:
        new = json.loads(base64.b64decode(sys.stdin.read()))
        data["items"] = [new if i["id"] == args[2] else i for i in data["items"]]
        data["edit"] += 1; save(); print(json.dumps(new))
    else:
        sys.exit(9)
    """
)


class SeedIdentitaTests(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.TemporaryDirectory()
        base = Path(self.dir.name)
        self.identity = base / "nixos/identity"
        self.identity.mkdir(parents=True)
        self.files = {}
        for nome in NOMI:
            path = self.identity / nome
            path.write_text(f'{{ {nome} = "{SEGRETO}"; }}\n')
            self.files[f"casa/identity/{nome}"] = path
        privacy = base / "nixos/privacy.json"
        privacy.write_text(json.dumps({"literals": [SEGRETO]}))
        self.files["casa/identity/privacy.json"] = privacy
        self.bw = base / "bw"
        self.bw.write_text(FAKE_BW)
        self.bw.chmod(0o755)
        self.store = base / "store.json"
        # Note conformi; una voce civetta con un nome che contiene un altro.
        items = [
            {"id": f"id{n}", "name": name, "notes": path.read_text()}
            for n, (name, path) in enumerate(self.files.items())
        ]
        items.append(
            {"id": "civetta", "name": "casa/identity/home.nix.vecchio", "notes": "x"}
        )
        self.write_store(items)

    def tearDown(self):
        self.dir.cleanup()

    def write_store(self, items):
        self.store.write_text(
            json.dumps({"items": items, "unlock": 0, "sync": 0, "lock": 0, "edit": 0})
        )

    def state(self):
        return json.loads(self.store.read_text())

    def run_seed(self, *args, session=True):
        env = {
            **os.environ,
            "BW": str(self.bw),
            "FAKE_BW_STORE": str(self.store),
            "NIXOS_IDENTITY_DIR": str(self.identity),
        }
        env.pop("BW_SESSION", None)
        if session:
            env["BW_SESSION"] = "aperta"
        result = subprocess.run(
            [str(SCRIPT), *args], env=env, capture_output=True, text=True, check=False
        )
        self.assertNotIn(SEGRETO, result.stdout + result.stderr)
        return result

    def test_verifica_conforme_e_blocca(self):
        result = self.run_seed("verifica")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.count("conforme"), 4)
        state = self.state()
        self.assertEqual((state["lock"], state["edit"], state["unlock"]), (1, 0, 0))

    def test_verifica_segnala_differenza_senza_scrivere(self):
        self.files["casa/identity/home.nix"].write_text("cambiato\n")
        result = self.run_seed("verifica")
        self.assertEqual(result.returncode, 1)
        self.assertIn("casa/identity/home.nix NON conforme", result.stderr)
        self.assertEqual(self.state()["edit"], 0)

    def test_aggiorna_scrive_solo_le_note_diverse(self):
        self.files["casa/identity/work.nix"].write_text("nuovo\n")
        result = self.run_seed("aggiorna")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.state()["edit"], 1)
        self.assertEqual(self.run_seed("verifica").returncode, 0)

    def test_nota_assente(self):
        items = [
            i for i in self.state()["items"] if i["name"] != "casa/identity/work.nix"
        ]
        self.write_store(items)
        result = self.run_seed("aggiorna")
        self.assertEqual(result.returncode, 1)
        self.assertIn("casa/identity/work.nix assente", result.stderr)

    def test_sblocca_senza_sessione(self):
        self.assertEqual(self.run_seed("verifica", session=False).returncode, 0)
        self.assertEqual(self.state()["unlock"], 1)

    def test_uso_e_file_mancanti(self):
        self.assertEqual(self.run_seed().returncode, 2)
        self.assertEqual(self.run_seed("ripristina").returncode, 2)
        self.files["casa/identity/privacy.json"].unlink()
        self.assertEqual(self.run_seed("verifica").returncode, 2)
        self.assertEqual(self.state()["sync"], 0)


if __name__ == "__main__":
    unittest.main()
