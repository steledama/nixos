"""Serve `view/` sulle reti private: lancio manuale o servizio permanente.

Stesso comando in ogni repo: `python3 o3/view/serve.py`, su Windows
`py o3\\view\\serve.py`, porta 8000, Ctrl-C per chiudere: serve l'anteprima
generata in `view/` dal working tree. Il servizio permanente dell'host
privilegiato lancia questo stesso script del checkout con `--port` e
`--publish-root` (`kb/view.md`, «Pubblicazione»). Solo libreria standard, così gira
anche sugli host Windows. Pubblica la sola cartella servita, che è chiusa
su se stessa (`kb/view.md`, «Compartimento stagno»): niente
dotfile e niente elenchi di cartella. La porta va ammessa dal firewall
dell'host solo verso le reti private; il server non lo tocca.

Con `--publish-root DIR` serve invece la versione pubblicata da
`build.py --publish DIR`: il puntatore `current` si rilegge a ogni
richiesta, così uno scambio di versione non chiede riavvii e una richiesta
già iniziata finisce sulla sua versione. `/_stato` rende `status.json`:
revisione servita, ultimo tentativo ed eventuale errore. Senza alcuna
versione valida il server non parte, dice perché ed esce con il codice 3,
distinto dagli altri errori; `--check` fa solo questo controllo (0 o 3), per
esempio come `ExecCondition` di un servizio.

Con `--ciclo-state DIR` serve anche `/_ciclo/`, lo stato dei tentativi
del ciclo autonomo letto a ogni richiesta (`ciclo.py`); senza, `/_ciclo/`
dichiara che il repo non ha un ciclo autonomo. `--ciclo-unita DIR` indica la
cartella dell'unità quando i tentativi stanno nel repo (`i1/giri`).
"""

from __future__ import annotations

import argparse
import io
import socket
import sys
from functools import partial
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlsplit

# Lanciato con `runpy` (il servizio di `danea-auto` su Windows) la cartella
# dello script non è in `sys.path`, e `ciclo` non si troverebbe.
sys.path.insert(0, str(Path(__file__).resolve().parent))

import ciclo

VIEW = Path(__file__).resolve().parents[2] / "view"
PORT = 8000
# Uscita per «nessuna versione valida»: un servizio la distingue da un crash.
NO_VALID_VERSION = 3


class ViewHandler(SimpleHTTPRequestHandler):
    ciclo_state: Path | None = None
    ciclo_unit: Path | None = None

    def send_head(self):
        path = unquote(urlsplit(self.path).path)
        if any(part.startswith(".") for part in path.split("/") if part):
            self.send_error(HTTPStatus.NOT_FOUND)
            return None
        if path.startswith("/" + ciclo.PREFIX):
            return self.send_ciclo(path)
        return super().send_head()

    def send_ciclo(self, path: str):
        answer = ciclo.respond(path, self.ciclo_state, self.ciclo_unit)
        if answer is None:
            self.send_error(HTTPStatus.NOT_FOUND)
            return None
        content_type, data = answer
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        return io.BytesIO(data)

    def list_directory(self, path):
        self.send_error(HTTPStatus.NOT_FOUND)


class PublishedHandler(ViewHandler):
    """Serve la versione nominata dal puntatore al momento della richiesta."""

    root: Path

    def __init__(self, *args, **kwargs):
        name = (self.root / "current").read_text(encoding="utf-8").strip()
        super().__init__(*args, directory=str(self.root / "releases" / name), **kwargs)

    def send_head(self):
        if urlsplit(self.path).path == "/_stato":
            try:
                data = (self.root / "status.json").read_bytes()
            except FileNotFoundError:
                self.send_error(HTTPStatus.NOT_FOUND)
                return None
            self.send_response(HTTPStatus.OK)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(data)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            return io.BytesIO(data)
        return super().send_head()


def served_folder(root: Path) -> Path:
    """La versione pubblicata, o l'uscita con la diagnosi se non ce n'è una valida."""
    try:
        name = (root / "current").read_text(encoding="utf-8").strip()
    except FileNotFoundError:
        name = ""
    folder = root / "releases" / name
    if name and (folder / "index.html").exists():
        return folder
    status = root / "status.json"
    detail = (
        status.read_text(encoding="utf-8") if status.exists() else "nessun tentativo registrato"
    )
    print(
        f"serve: nessuna versione valida in {root}; esegui build.py --publish {root}\n{detail}",
        file=sys.stderr,
    )
    raise SystemExit(NO_VALID_VERSION)


def lan_addresses() -> list[str]:
    """Gli indirizzi con cui gli altri PC raggiungono questo host."""
    addresses: set[str] = set()
    try:
        # Nessun pacchetto parte: connect su UDP sceglie solo l'interfaccia d'uscita.
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as probe:
            probe.connect(("192.0.2.1", 9))
            addresses.add(probe.getsockname()[0])
    except OSError:
        pass
    try:
        for info in socket.getaddrinfo(socket.gethostname(), None, socket.AF_INET):
            addresses.add(info[4][0])
    except OSError:
        pass
    return sorted(address for address in addresses if not address.startswith("127."))


def main() -> None:
    parser = argparse.ArgumentParser(description="Serve view/ sulle reti private")
    parser.add_argument("--port", type=int, default=PORT, help=f"porta TCP (default {PORT})")
    parser.add_argument(
        "--bind", default="0.0.0.0", help="indirizzo d'ascolto (default: tutte le interfacce)"
    )
    parser.add_argument(
        "--publish-root", type=Path, help="serve la versione pubblicata da build.py --publish"
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help=f"con --publish-root: esce con 0 se c'è una versione valida, {NO_VALID_VERSION} se no",
    )
    parser.add_argument(
        "--ciclo-state",
        type=Path,
        help="cartella dei tentativi del ciclo autonomo (i1/giri del repo, o lo stato dell'unità)",
    )
    parser.add_argument(
        "--ciclo-unita",
        type=Path,
        help="cartella di stato dell'unità (~/.local/state/ciclo/<repo>), se diversa da --ciclo-state",
    )
    args = parser.parse_args()
    state = args.ciclo_state.expanduser().resolve() if args.ciclo_state else None
    unit = args.ciclo_unita.expanduser().resolve() if args.ciclo_unita else None
    if unit and not state:
        parser.error("--ciclo-unita richiede --ciclo-state")
    cycle = {"ciclo_state": state, "ciclo_unit": unit}

    if args.check and not args.publish_root:
        parser.error("--check richiede --publish-root")
    if args.publish_root:
        root = args.publish_root.resolve()
        folder = served_folder(root)
        if args.check:
            print(f"serve: versione valida {folder.name}")
            return
        handler = type("Handler", (PublishedHandler,), {"root": root, **cycle})
    else:
        folder = VIEW
        if not (VIEW / "index.html").exists():
            raise SystemExit("serve: view/index.html assente, esegui prima build.py")
        handler = partial(type("Handler", (ViewHandler,), cycle), directory=str(VIEW))
    with ThreadingHTTPServer((args.bind, args.port), handler) as server:
        hosts = ["localhost"]
        if args.bind in {"0.0.0.0", ""}:
            hosts += lan_addresses() + [socket.gethostname()]
        elif args.bind not in {"127.0.0.1", "localhost"}:
            hosts = [args.bind]
        print(f"Viste da {folder} — Ctrl-C per chiudere", flush=True)
        for host in hosts:
            print(f"  http://{host}:{args.port}/", flush=True)
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            print("\nChiuso.")


if __name__ == "__main__":
    main()
