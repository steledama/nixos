"""Contratto di cache-status.sh: esiti per cache e simbolo aggregato, senza rete
esterna (server HTTP locale)."""

import http.server
import os
import subprocess
import threading
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SCRIPT = ROOT / "o3/scripts/cache-status.sh"

HASH = "0" * 31 + "a"
STORE_PATH = f"/nix/store/{HASH}-whisper-cpp-1.9.2"
CODES = {"ok": 200, "missing": 404, "denied": 401, "forbidden": 403, "broken": 500}


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):  # noqa: N802 - nome imposto da http.server
        prefix, _, name = self.path.strip("/").partition("/")
        code = CODES.get(prefix, 404) if name == f"{HASH}.narinfo" else 404
        self.send_response(code)
        self.end_headers()
        if code == 200:
            self.wfile.write(f"StorePath: {STORE_PATH}\n".encode())

    def log_message(self, *args):
        pass


class CacheStatusTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        cls.base = f"http://127.0.0.1:{cls.server.server_address[1]}"
        threading.Thread(target=cls.server.serve_forever, daemon=True).start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()

    def cache(self, kind):
        return f"{self.base}/{kind}/"

    def run_status(self, *caches, path=STORE_PATH):
        result = subprocess.run(
            [str(SCRIPT), "-v", path, *caches],
            capture_output=True,
            text=True,
            check=True,
            env={**os.environ, "CACHE_TIMEOUT": "5"},
        )
        detail = dict(line.rsplit(" ", 1) for line in result.stderr.splitlines())
        return result.stdout.strip(), detail

    def test_presente_in_una_cache_basta(self):
        symbol, detail = self.run_status(self.cache("missing"), self.cache("ok"))
        self.assertEqual(symbol, "✓")
        self.assertEqual(detail[self.cache("ok").rstrip("/")], "presente")
        self.assertEqual(detail[self.cache("missing").rstrip("/")], "assente")

    def test_presente_vince_su_errori(self):
        symbol, _ = self.run_status(
            self.cache("denied"), "http://127.0.0.1:1", self.cache("ok")
        )
        self.assertEqual(symbol, "✓")

    def test_assente_in_tutte(self):
        symbol, _ = self.run_status(self.cache("missing"), self.cache("missing") + "x")
        self.assertEqual(symbol, "✗")

    def test_accesso_negato(self):
        for kind in ("denied", "forbidden"):
            symbol, detail = self.run_status(self.cache("missing"), self.cache(kind))
            self.assertEqual(symbol, "!")
            self.assertEqual(detail[self.cache(kind).rstrip("/")], "accesso-negato")

    def test_non_verificata(self):
        for cache in (self.cache("broken"), "http://127.0.0.1:1", "file:///tmp/c"):
            symbol, detail = self.run_status(self.cache("missing"), cache)
            self.assertEqual(symbol, "?", cache)
            self.assertEqual(detail[cache.rstrip("/")], "non-verificata")

    def test_senza_cache_o_path_invalido(self):
        self.assertEqual(self.run_status()[0], "?")
        self.assertEqual(self.run_status(self.cache("ok"), path="/tmp/whisper")[0], "?")
        self.assertEqual(
            self.run_status(self.cache("ok"), path="/nix/store/corto-x")[0], "?"
        )


if __name__ == "__main__":
    unittest.main()
