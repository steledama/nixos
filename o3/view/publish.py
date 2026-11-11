"""Pubblica le viste da un commit pulito, conservando l'ultima vista buona.

La vista pubblicata non è `view/` del checkout: vive in una cartella di
pubblicazione dell'host, fuori dal working tree, con una sottocartella per
versione in `releases/` e un puntatore `current` che nomina quella servita.
`serve.py --publish-root` legge il puntatore a ogni richiesta.

- **Fonti stabili**: il commit si esporta con `git archive` in una cartella
  temporanea e la build gira sui builder di quel commit. Né le modifiche
  locali né i file non tracciati entrano nell'output, e un pull o un edit
  durante la build non mescolano le revisioni.
- **Ultima vista buona**: la build scrive in una cartella `.partial`; solo a
  build riuscita la cartella prende il suo nome e il puntatore cambia con
  `os.replace`, atomico anche su Windows. Un errore lascia intatta la
  versione servita e finisce in `status.json`.
- **Richieste concorrenti**: un lock serializza le pubblicazioni. Chi lo trova
  occupato lascia una richiesta pendente e chi lo tiene, finito il giro,
  ripubblica la revisione più recente: l'ultimo commit richiesto arriva
  comunque, anche dopo una build fallita. Il lock porta il PID: un lock
  lasciato da un processo morto (SIGKILL, host spento) si riprende subito, e
  un SIGTERM chiude il giro dal `finally` come un'uscita normale. Si tengono la versione corrente e la precedente, così una
  richiesta HTTP iniziata prima dello scambio finisce sulla sua versione.

Solo libreria standard: gira anche sugli host Windows.
"""

from __future__ import annotations

import io
import json
import os
import shutil
import signal
import subprocess
import sys
import tarfile
import tempfile
import time
from collections.abc import Callable
from datetime import UTC, datetime
from pathlib import Path

RELEASES = "releases"
POINTER = "current"
STATUS = "status.json"
LOCK = ".lock"
PENDING = ".pending"
# Oltre questa età un lock non si rispetta neppure se il PID risulta vivo:
# dopo un riavvio il PID può essere stato riassegnato.
STALE_LOCK = 30 * 60
# Giri massimi per inseguire commit arrivati durante la pubblicazione.
MAX_ROUNDS = 5

Builder = Callable[[Path, Path, str], None]


def git(repo: Path, *args: str) -> str:
    return subprocess.run(
        ["git", "-C", str(repo), *args],
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=True,
    ).stdout.strip()


def resolve(repo: Path, rev: str) -> str:
    return git(repo, "rev-parse", "--verify", f"{rev}^{{commit}}")


def export(repo: Path, commit: str, target: Path) -> None:
    """Le fonti del commit, senza working tree né file non tracciati."""
    archive = subprocess.run(
        ["git", "-C", str(repo), "archive", "--format=tar", commit],
        capture_output=True,
        check=True,
    ).stdout
    with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
        tar.extractall(target, filter="tar")


def build_with_commit_builders(source: Path, out: Path, commit: str) -> None:
    """Costruisce con i builder del commit stesso: provenienza intera."""
    result = subprocess.run(
        [
            sys.executable,
            str(source / "o3" / "view" / "build.py"),
            "--out",
            str(out),
            "--commit",
            commit,
        ],
        cwd=source,
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError((result.stdout + result.stderr).strip() or "build fallita")


def current(dest: Path) -> str | None:
    """Il nome della versione servita, se il puntatore nomina una cartella che esiste."""
    try:
        name = (dest / POINTER).read_text(encoding="utf-8").strip()
    except FileNotFoundError:
        return None
    return name if name and (dest / RELEASES / name).is_dir() else None


def served_commit(dest: Path) -> str | None:
    name = current(dest)
    if name is None:
        return None
    try:
        data = json.loads((dest / RELEASES / name / "provenance.json").read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError):
        return None
    return data.get("commit")


def write_atomic(path: Path, text: str) -> None:
    tmp = path.with_name(f"{path.name}.tmp")
    tmp.write_bytes(text.encode("utf-8"))
    os.replace(tmp, path)


def write_status(dest: Path, **fields: object) -> None:
    status = {"served": current(dest), "served_commit": served_commit(dest), **fields}
    status["time"] = datetime.now(UTC).isoformat(timespec="seconds")
    write_atomic(dest / STATUS, json.dumps(status, indent=2, ensure_ascii=False) + "\n")


def alive(pid: int) -> bool:
    if os.name == "nt":
        # Su Windows os.kill(pid, 0) termina il processo: si chiede al kernel.
        import ctypes

        kernel32 = ctypes.windll.kernel32
        handle = kernel32.OpenProcess(0x1000, False, pid)  # QUERY_LIMITED_INFORMATION
        if not handle:
            return False
        code = ctypes.c_ulong()
        kernel32.GetExitCodeProcess(handle, ctypes.byref(code))
        kernel32.CloseHandle(handle)
        return code.value == 259  # STILL_ACTIVE
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    return True


def stale(lock: Path) -> bool:
    try:
        if time.time() - lock.stat().st_mtime > STALE_LOCK:
            return True
        pid = int(lock.read_text(encoding="utf-8").strip() or 0)
    except FileNotFoundError:
        return False
    except ValueError:
        # Lock appena creato e non ancora scritto: lo rispettiamo.
        return False
    return pid > 0 and not alive(pid)


def acquire(dest: Path) -> bool:
    lock = dest / LOCK
    if stale(lock):
        lock.unlink(missing_ok=True)
    try:
        fd = os.open(lock, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
    except FileExistsError:
        return False
    os.write(fd, str(os.getpid()).encode())
    os.close(fd)
    return True


def prune(dest: Path, keep: set[str]) -> None:
    """Rimuove le versioni non più servite e i resti di build interrotte.

    Su Windows una cartella con file aperti non si cancella: resta al giro dopo.
    """
    for path in (dest / RELEASES).iterdir():
        if path.name not in keep:
            shutil.rmtree(path, ignore_errors=True)


def publish_once(repo: Path, dest: Path, commit: str, builder: Builder) -> str:
    name = f"{datetime.now(UTC):%Y%m%dT%H%M%S}-{commit[:12]}"
    partial = dest / RELEASES / f"{name}.partial"
    with tempfile.TemporaryDirectory(prefix="view-src-") as tmp:
        source = Path(tmp)
        export(repo, commit, source)
        try:
            builder(source, partial, commit)
        except BaseException:
            shutil.rmtree(partial, ignore_errors=True)
            raise
    os.replace(partial, dest / RELEASES / name)
    previous = current(dest)
    write_atomic(dest / POINTER, name + "\n")
    prune(dest, {name, previous} - {None})
    return name


def publish(repo: Path, dest: Path, rev: str = "HEAD", builder: Builder | None = None) -> int:
    """Pubblica `rev` in `dest`; 0 se la versione servita è quella richiesta."""
    builder = builder or build_with_commit_builders
    (dest / RELEASES).mkdir(parents=True, exist_ok=True)
    if not acquire(dest):
        (dest / PENDING).touch()
        print(f"publish: pubblicazione già in corso in {dest}, richiesta accodata")
        return 0
    # systemd ferma la unit con SIGTERM: diventa un'uscita che passa dal finally.
    previous_handler = signal.signal(signal.SIGTERM, lambda *_: sys.exit(143))
    try:
        result = 0
        for _ in range(MAX_ROUNDS):
            (dest / PENDING).unlink(missing_ok=True)
            commit = resolve(repo, rev)
            if served_commit(dest) == commit:
                write_status(dest, ok=True, requested=commit)
                print(f"publish: {commit[:12]} già servito")
                result = 0
            else:
                try:
                    name = publish_once(repo, dest, commit, builder)
                except Exception as error:  # noqa: BLE001 — l'errore va nello stato, non perso
                    write_status(dest, ok=False, requested=commit, error=str(error))
                    print(
                        f"publish: build di {commit[:12]} fallita, resta servita "
                        f"{current(dest) or 'nessuna versione'}\n{error}",
                        file=sys.stderr,
                    )
                    result = 1
                except BaseException:
                    # SIGTERM o Ctrl-C: la versione servita resta, ma lo stato
                    # dice che la richiesta non è arrivata.
                    write_status(dest, ok=False, requested=commit, error="pubblicazione interrotta")
                    raise
                else:
                    write_status(dest, ok=True, requested=commit)
                    print(f"publish: pubblicata {name}")
                    result = 0
            # Un commit arrivato durante la build si pubblica ora, anche se
            # la build appena chiusa è fallita.
            if not (dest / PENDING).exists() and resolve(repo, rev) == commit:
                return result
        return result
    finally:
        (dest / LOCK).unlink(missing_ok=True)
        signal.signal(signal.SIGTERM, previous_handler)
