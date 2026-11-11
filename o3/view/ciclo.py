"""Il ciclo autonomo nella vista: lo stato dei tentativi letto a richiesta.

La release si costruisce dal commit; il ciclo autonomo cambia anche senza commit,
quindi non entra nella release ma si legge quando la si chiede, come
`/_stato` rende `status.json`. `serve.py --ciclo-state DIR` passa la
cartella dei tentativi (`tentativi.jsonl` e `giri/`) e `--ciclo-unita DIR`
la cartella di stato dell'unità che il modulo `cicli` di `nixos` scrive per il
repo (`~/.local/state/ciclo/<repo>/`), accanto a `decisioni.json`. Le due
coincidono finché il repo non dichiara `giri` (es. `i1/giri`, `kb/perceive.md`);
senza `--ciclo-unita` vale la prima. Risponde sotto `/_ciclo/`:

- `/_ciclo/ultimi.json`: gli ultimi tentativi col semaforo, letti dallo
  script della home;
- `/_ciclo/`: tutti i tentativi conservati;
- `/_ciclo/<id>`: la pagina del giro; `/_ciclo/<id>.jsonl`: lo stream.

Contratto in `kb/view.md` («Stato operativo letto a richiesta»). Il semaforo si calcola da campi espliciti e il giudizio dell'agente
alza, non abbassa. Il prossimo task arriva dal trailer `Prossimo:` del commit
del giro e si confronta con quello precedente nella storia: un cambio di
priorità porta il giro a giallo, anche se l'agente lo dichiara confermato.
La riga lo nomina solo in quel motivo, perché lo stato della coda vive nel
plan; la pagina del giro lo riporta sempre.
Solo libreria standard, come `serve.py`.
"""

from __future__ import annotations

import html
import json
import re
import subprocess
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from pathlib import Path

import project
from sources import inline_markdown, parse_plan

PREFIX = "_ciclo/"
HOME_ROWS = 5
# Oltre l'orario atteso, quanto aspettare prima di dichiarare la partenza
# mancata; e oltre il tempo massimo, quanto prima di dichiarare un giro
# senza chiusura.
LATE_START = timedelta(hours=1)
LATE_CLOSE = timedelta(minutes=10)
ID = re.compile(r"^[0-9a-f]{32}$")
ATTENTION = re.compile(r"^\s*\**Attenzione:?\**:?\s*(.*)$", re.IGNORECASE)
# `<task> (confermato)`, `<task> (cambiato, era <task>; motivo)`, `nessuno (motivo)`.
NEXT = re.compile(r"^(.*?)\s*\((confermato|cambiato)\b(?:,\s*era\s+([^;)]*))?[^)]*\)\s*$")
REPO = Path(__file__).resolve().parents[2]

LABELS = {
    "it": {
        "title": "Ciclo autonomo",
        "section": "Esiti degli ultimi cicli autonomi",
        "all": "Tutti i tentativi",
        "back": "Home",
        "read": "Letto alle",
        "none": "Nessun ciclo autonomo dichiarato per questo repo.",
        "external": "Ciclo autonomo fuori nixos",
        "never": "Ciclo autonomo dichiarato, nessun tentativo ancora.",
        "unreadable": "Fonte del ciclo autonomo non leggibile",
        "offline": "Il ciclo autonomo si legge dalla vista servita, non dal file aperto.",
        "verde": "riuscito",
        "giallo": "riuscito, da guardare",
        "rosso": "bloccato",
        "in-corso": "in corso",
        "missed": "partenza mancata",
        "no-close": "senza chiusura oltre il tempo massimo",
        "no-push": "commit senza push",
        "no-commit": "nessun commit",
        "denials": "permessi negati",
        "no-attention": "riga «Attenzione» assente",
        "no-next": "prossimo task assente",
        "no-history": "storia git non leggibile, prossimo task non verificato",
        "not-released": "commit del giro non ancora nel checkout servito",
        "changed": "priorità cambiata",
        "undeclared": "dichiarata confermata",
        "next": "Prossimo task",
        "previous": "prima",
        "report": "Resoconto",
        "attention": "Attenzione",
        "actions": "Comandi e strumenti",
        "stream": "Stream completo del giro",
        "commit": "Commit",
        "meta": "Tentativo",
    },
    "en": {
        "title": "Autonomous cycle",
        "section": "Latest autonomous cycle results",
        "all": "All attempts",
        "back": "Home",
        "read": "Read at",
        "none": "No autonomous cycle declared for this repo.",
        "external": "Autonomous cycle outside nixos",
        "never": "Autonomous cycle declared, no attempt yet.",
        "unreadable": "Autonomous cycle source not readable",
        "offline": "The autonomous cycle is read from the served view, not the opened file.",
        "verde": "succeeded",
        "giallo": "succeeded, needs a look",
        "rosso": "blocked",
        "in-corso": "running",
        "missed": "missed start",
        "no-close": "no closing past the maximum runtime",
        "no-push": "commit without push",
        "no-commit": "no commit",
        "denials": "permissions denied",
        "no-attention": "«Attenzione» line missing",
        "no-next": "next task missing",
        "no-history": "git history unreadable, next task not checked",
        "not-released": "round commit not yet in the served checkout",
        "changed": "priority changed",
        "undeclared": "declared as confirmed",
        "next": "Next task",
        "previous": "before",
        "report": "Report",
        "attention": "Attention",
        "actions": "Commands and tools",
        "stream": "Full stream of the round",
        "commit": "Commit",
        "meta": "Attempt",
    },
}


def label(kind: str) -> str:
    return LABELS.get(project.LINGUA, LABELS["en"])[kind]


@dataclass
class Attempt:
    id: str
    start: dict | None = None
    close: dict | None = None
    color: str = "giallo"
    reasons: list[str] = field(default_factory=list)
    attention: str | None = None
    missed: bool = False
    next_task: str | None = None
    previous_task: str | None = None
    changed_task_href: str | None = None

    @property
    def when(self) -> str:
        record = self.start or self.close or {}
        return record.get("ts") or record.get("ts_partenza") or ""


def parse_time(value: str) -> datetime | None:
    try:
        return datetime.fromisoformat(value)
    except (TypeError, ValueError):
        return None


def duration(text: str | None) -> timedelta:
    """`45min`, `2h`, `90s` o secondi nudi, come `RuntimeMaxSec`."""
    match = re.fullmatch(r"\s*(\d+)\s*(h|min|m|s)?\s*", text or "")
    if not match:
        return timedelta(hours=1)
    value, unit = int(match.group(1)), match.group(2) or "s"
    return timedelta(
        **{"h": {"hours": value}, "s": {"seconds": value}}.get(unit, {"minutes": value})
    )


def read_jsonl(path: Path) -> list[dict]:
    records = []
    for line in path.read_text(encoding="utf-8").splitlines():
        try:
            records.append(json.loads(line))
        except json.JSONDecodeError:
            continue
    return records


def stream_result(state: Path, attempt_id: str) -> dict | None:
    path = state / "giri" / f"{attempt_id}.jsonl"
    if not path.is_file():
        return None
    results = [event for event in read_jsonl(path) if event.get("type") == "result"]
    return results[-1] if results else None


def attention_of(close: dict, result: dict | None) -> str | None:
    """`""` per «nessuna», il testo delle voci, None se la riga manca."""
    if "attenzione" in close and close["attenzione"] is not None:
        value = str(close["attenzione"]).strip()
        return "" if value.lower() in {"", "nessuna"} else value
    text = (result or {}).get("result") or ""
    for line in reversed(text.splitlines()):
        match = ATTENTION.match(line)
        if match:
            value = match.group(1).strip().strip("*").strip()
            return "" if value.lower().rstrip(".") == "nessuna" else value
    return None


def git(*args: str) -> str | None:
    """L'output di git nel repo della vista, None se git non risponde.

    Su Windows senza finestra: una console aperta durante uno slot ruberebbe il
    primo piano all'automazione della GUI (`danea-auto`).
    """
    try:
        return subprocess.run(
            ["git", "-C", str(REPO), *args],
            capture_output=True,
            text=True,
            check=True,
            timeout=10,
            creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
        ).stdout
    except (OSError, subprocess.SubprocessError):
        return None


def trailer_next(rev: str, limit: int = 1) -> str | None:
    """Il primo trailer `Prossimo:` da `rev` all'indietro, `""` se non c'è."""
    out = git("log", f"-{limit}", "--format=%(trailers:key=Prossimo,valueonly,separator=%x0A)", rev)
    if out is None:
        return None
    return next((line.strip() for line in out.splitlines() if line.strip()), "")


def task_of(value: str) -> tuple[str, str | None, str | None]:
    """Task, dichiarazione (`confermato`/`cambiato`/None) e task precedente dichiarato."""
    match = NEXT.match(value)
    if not match:
        return value.split(" (")[0].strip(), None, None
    return match.group(1).strip(), match.group(2), (match.group(3) or "").strip() or None


def same(a: str, b: str) -> bool:
    return " ".join(a.split()).casefold() == " ".join(b.split()).casefold()


def task_href(task: str) -> str | None:
    """La pagina del task nel plan corrente: None se è uscito dal plan, se non
    ha una specifica `o2/` o se la copia servita non ha le fonti."""
    try:
        rows = parse_plan(REPO)
    except (OSError, SystemExit):
        return None
    source = next((row.source for row in rows if row.source and same(row.task, task)), None)
    return f"/{source.removesuffix('.md')}.html" if source else None


def judge_next(attempt: Attempt, close: dict, reasons: list[str]) -> None:
    """Prossimo task del giro e confronto col precedente; senza git lo dichiara."""
    head = close.get("head_dopo")
    if not close.get("commit") or not head:
        return
    current = trailer_next(head)
    if current is None:
        # Una vista servita da una copia senza `.git` non tace: il confronto manca.
        # Con la storia leggibile manca solo il commit: il giro ha lavorato in un
        # clone e il checkout servito non l'ha ancora tirato (`danea-auto`).
        readable = git("rev-parse", "--git-dir") is not None
        reasons.append(label("not-released" if readable else "no-history"))
        return
    before = trailer_next(f"{head}^", limit=200)
    if not current:
        # Prima del recepimento la storia non ha trailer: nessun giallo retroattivo.
        if before:
            reasons.append(label("no-next"))
        return
    task, declared, was = task_of(current)
    attempt.next_task = task
    previous = task_of(before)[0] if before else was
    attempt.previous_task = previous
    if previous and not same(previous, task):
        note = f"{label('changed')}: {previous} → {task}"
        if declared == "confermato":
            note += f" ({label('undeclared')})"
        reasons.append(note)
        attempt.changed_task_href = task_href(task)


def judge(attempt: Attempt, state: Path, decision: dict, now: datetime) -> None:
    close = attempt.close
    if close is None:
        start = parse_time(attempt.when)
        limit = duration(decision.get("maxRuntime")) + LATE_CLOSE
        if start and now - start > limit:
            attempt.color, attempt.reasons = "rosso", [label("no-close")]
        else:
            attempt.color = "in-corso"
        return
    if close.get("esito") != "riuscito":
        attempt.color = "rosso"
        attempt.reasons = [str(close.get("motivo") or close.get("esito") or "?")]
        return
    if close.get("commit") and not close.get("push"):
        attempt.color, attempt.reasons = "rosso", [label("no-push")]
        return
    attempt.attention = attention_of(close, stream_result(state, attempt.id))
    reasons = []
    if not close.get("commit"):
        reasons.append(label("no-commit"))
    if close.get("permission_denials"):
        reasons.append(f"{label('denials')}: {close['permission_denials']}")
    if attempt.attention is None:
        reasons.append(label("no-attention"))
    elif attempt.attention:
        reasons.append(attempt.attention)
    judge_next(attempt, close, reasons)
    attempt.color = "giallo" if reasons else "verde"
    attempt.reasons = reasons


def expected_start(decision: dict, now: datetime) -> datetime | None:
    """L'ultima partenza attesa, per la sola cadenza giornaliera `*-*-*`.

    Le altre forme di `OnCalendar` non si interpretano qui: per loro la
    partenza mancata non si calcola, ed è un limite dichiarato.
    """
    if decision.get("state") != "timer" or decision.get("cadence") != "*-*-*":
        return None
    match = re.fullmatch(r"(\d{1,2}):(\d{2})", decision.get("time") or "")
    if not match:
        return None
    hour, minute = int(match.group(1)), int(match.group(2))
    today = now.replace(hour=hour, minute=minute, second=0, microsecond=0)
    expected = today if today + LATE_START <= now else today - timedelta(days=1)
    return expected


def load(state: Path | None, now: datetime | None = None, unit: Path | None = None) -> dict:
    """Lo stato del ciclo autonomo: `stato` dice perché mancano tentativi, se mancano.

    `state` tiene i tentativi; `unit`, se diversa, è la cartella dell'unità, la
    cui madre porta `decisioni.json` alla chiave del suo nome (il repo).
    """
    now = now or datetime.now().astimezone()
    view = {"letto": now.isoformat(timespec="seconds"), "stato": "ok", "tentativi": []}
    if state is None:
        view["stato"] = "none"
        return view
    unit = unit or state
    decision: dict = {}
    try:
        decisions = json.loads((unit.parent / "decisioni.json").read_text(encoding="utf-8"))
        decision = decisions.get(unit.name) or {}
    except (OSError, json.JSONDecodeError):
        pass
    if decision.get("state") == "esterno":
        view["stato"] = "external"
        view["nota"] = decision.get("note") or ""
        return view
    try:
        records = read_jsonl(state / "tentativi.jsonl")
    except FileNotFoundError:
        # La cartella di stato nasce col primo giro: un ciclo dichiarato che
        # non è mai partito non ha ancora fonte, ma non è illeggibile.
        view["stato"] = "never" if state.is_dir() or decision else "unreadable"
        records = []
    except OSError:
        view["stato"] = "unreadable"
        return view
    attempts: dict[str, Attempt] = {}
    for record in records:
        attempt_id = str(record.get("id") or "")
        attempt = attempts.setdefault(attempt_id, Attempt(attempt_id))
        if record.get("evento") == "partenza":
            attempt.start = record
        elif record.get("evento") == "chiusura":
            attempt.close = record
    for attempt in attempts.values():
        judge(attempt, state, decision, now)
    ordered = sorted(attempts.values(), key=lambda a: a.when, reverse=True)
    expected = expected_start(decision, now)
    if expected is not None:
        last = parse_time(ordered[0].when) if ordered else None
        if last is None or last < expected:
            missed = Attempt("", color="rosso", reasons=[label("missed")], missed=True)
            missed.start = {"ts": expected.isoformat(timespec="minutes")}
            ordered.insert(0, missed)
    view["tentativi"] = ordered
    if not ordered and view["stato"] == "ok":
        view["stato"] = "never"
    return view


def summary(attempt: Attempt) -> dict:
    close = attempt.close or {}
    changed = (
        {"task_cambiato": {"titolo": attempt.next_task, "href": attempt.changed_task_href}}
        if attempt.changed_task_href
        else {}
    )
    return {
        **changed,
        "id": attempt.id,
        "ts": attempt.when,
        "colore": attempt.color,
        "esito": label(attempt.color) if not attempt.missed else label("missed"),
        "motivi": attempt.reasons,
        "commit": close.get("head_dopo") if close.get("commit") else None,
        "durata_s": round(close["durata_ms"] / 1000) if close.get("durata_ms") else None,
        "costo_usd": close.get("costo_usd"),
    }


def status_text(view: dict) -> str:
    stato = view["stato"]
    if stato == "external":
        return f"{label('external')}: {view.get('nota') or ''}".rstrip(": ")
    return label(stato) if stato in {"none", "never", "unreadable"} else ""


def latest_json(state: Path | None, unit: Path | None = None) -> bytes:
    view = load(state, unit=unit)
    data = {
        "letto": view["letto"],
        "stato": view["stato"],
        "testo": status_text(view),
        "tentativi": [summary(a) for a in view["tentativi"][:HOME_ROWS]],
    }
    return json.dumps(data, ensure_ascii=False).encode("utf-8")


# --- Pagine ------------------------------------------------------------------


def page(title: str, body: str) -> bytes:
    return f"""<!doctype html>
<html lang="{html.escape(project.LINGUA)}">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{html.escape(project.SIGLA)} · {html.escape(title)}</title>
    <link rel="stylesheet" href="/assets/system-image.css" />
    <link rel="stylesheet" href="/assets/theme.css" />
  </head>
  <body>
    <main class="pole ciclo-pagina">
      <p><a href="/">{label("back")}</a> · <a href="/{PREFIX}">{label("all")}</a></p>
{body}
    </main>
  </body>
</html>
""".encode()


def row_html(attempt: Attempt) -> str:
    when = html.escape(attempt.when.replace("T", " ")[:16])
    text = html.escape(label(attempt.color) if not attempt.missed else label("missed"))
    reasons = html.escape(" · ".join(r for r in attempt.reasons if r != label("missed")))
    detail = f' <span class="ciclo-motivi">{reasons}</span>' if reasons else ""

    head = f'<span class="semaforo {attempt.color}" aria-hidden="true"></span>'
    if attempt.id:
        return f'<li>{head}<a href="/{PREFIX}{attempt.id}">{when} · {text}</a>{detail}</li>'
    return f"<li>{head}{when} · {text}{detail}</li>"


def list_page(state: Path | None, unit: Path | None = None) -> bytes:
    view = load(state, unit=unit)
    rows = "\n".join(row_html(a) for a in view["tentativi"])
    note = status_text(view)
    body = (
        f"      <h1>{label('title')}</h1>\n"
        f'      <p class="ciclo-letto">{label("read")} {html.escape(view["letto"])}</p>\n'
        + (f"      <p>{html.escape(note)}</p>\n" if note else "")
        + f'      <ol class="ciclo-righe">{rows}</ol>'
    )
    return page(label("title"), body)


def report_html(markdown: str) -> str:
    """Il resoconto dell'agente: titoli, liste annidate e prosa, niente HTML grezzo."""
    parts: list[str] = []
    depth: list[int] = []
    for raw in markdown.splitlines():
        line = raw.rstrip()
        heading = re.match(r"^(#{1,4})\s+(.*)$", line)
        item = re.match(r"^(\s*)[-*]\s+(.*)$", line)
        if item:
            indent = len(item.group(1))
            if not depth or indent > depth[-1]:
                parts.append("<ul>")
                depth.append(indent)
            while depth and indent < depth[-1]:
                parts.append("</ul>")
                depth.pop()
            parts.append(f"<li>{inline_markdown(item.group(2))}</li>")
            continue
        while depth:
            parts.append("</ul>")
            depth.pop()
        if heading:
            level = min(len(heading.group(1)) + 1, 4)
            parts.append(f"<h{level}>{inline_markdown(heading.group(2))}</h{level}>")
        elif line.strip():
            parts.append(f"<p>{inline_markdown(line.strip())}</p>")
    parts.extend("</ul>" for _ in depth)
    return "\n".join(parts)


def actions_of(state: Path, attempt_id: str) -> list[str]:
    path = state / "giri" / f"{attempt_id}.jsonl"
    if not path.is_file():
        return []
    actions = []
    for event in read_jsonl(path):
        if event.get("type") != "assistant":
            continue
        for block in (event.get("message") or {}).get("content") or []:
            if not isinstance(block, dict) or block.get("type") != "tool_use":
                continue
            data = block.get("input") or {}
            detail = (
                data.get("command")
                or data.get("skill")
                or data.get("file_path")
                or data.get("pattern")
                or data.get("url")
                or ""
            )
            actions.append(f"{block.get('name')}: {str(detail)[:300]}")
    return actions


def commit_message(close: dict) -> str | None:
    head = close.get("head_dopo")
    if not close.get("commit") or not head:
        return None
    out = git("log", "-1", "--format=%B", head)
    return out.strip() if out is not None else None


def attempt_page(state: Path | None, attempt_id: str, unit: Path | None = None) -> bytes | None:
    if state is None or not ID.match(attempt_id):
        return None
    view = load(state, unit=unit)
    attempt = next((a for a in view["tentativi"] if a.id == attempt_id), None)
    if attempt is None:
        return None
    record = {**(attempt.start or {}), **(attempt.close or {})}
    keys = [
        "ts", "esito", "motivo", "head_prima", "head_dopo", "commit", "push",
        "oggetto", "tree_sporco_dopo", "permission_denials", "costo_usd", "turni",
        "durata_ms",
        "exit_status", "service_result",
    ]  # fmt: skip
    meta = "".join(
        f"<dt>{html.escape(k)}</dt><dd>{html.escape(str(record[k]))}</dd>"
        for k in keys
        if k in record
    )
    result = stream_result(state, attempt_id) or {}
    sections = [
        (
            f'      <h1><span class="semaforo {attempt.color}" aria-hidden="true"></span>'
            f"{label('title')} · {html.escape(attempt.when.replace('T', ' ')[:16])}</h1>"
        ),
        f"      <p>{html.escape(label(attempt.color))}"
        + (f" — {html.escape(' · '.join(attempt.reasons))}" if attempt.reasons else "")
        + "</p>",
        f"      <h2>{label('meta')}</h2>\n      <dl>{meta}</dl>",
    ]
    if attempt.next_task:
        previous = (
            f" <small>({label('previous')}: {html.escape(attempt.previous_task)})</small>"
            if attempt.previous_task and not same(attempt.previous_task, attempt.next_task)
            else ""
        )
        sections.append(
            f"      <h2>{label('next')}</h2>\n"
            f"      <p>{html.escape(attempt.next_task)}{previous}</p>"
        )
    message = commit_message(attempt.close or {})
    if message:
        sections.append(
            f"      <h2>{label('commit')}</h2>\n      <pre>{html.escape(message)}</pre>"
        )
    if result.get("result"):
        sections.append(f"      <h2>{label('report')}</h2>\n{report_html(result['result'])}")
    denials = result.get("permission_denials") or []
    actions = actions_of(state, attempt_id)
    if actions:
        items = "".join(f"<li><code>{html.escape(a)}</code></li>" for a in actions)
        sections.append(
            f"      <h2>{label('actions')} ({len(actions)})</h2>\n      <ol>{items}</ol>"
        )
    if denials:
        items = "".join(
            f"<li><code>{html.escape(json.dumps(d.get('tool_input'), ensure_ascii=False)[:300])}</code></li>"
            for d in denials
        )
        sections.append(f"      <h2>{label('denials')}</h2>\n      <ol>{items}</ol>")
    if (state / "giri" / f"{attempt_id}.jsonl").is_file():
        sections.append(f'      <p><a href="/{PREFIX}{attempt_id}.jsonl">{label("stream")}</a></p>')
    return page(f"{label('title')} {attempt.when[:16]}", "\n".join(sections))


def respond(path: str, state: Path | None, unit: Path | None = None) -> tuple[str, bytes] | None:
    """La risposta a un path sotto `/_ciclo/`: tipo e corpo, o None per il 404."""
    rest = path[len("/" + PREFIX) :]
    if rest == "ultimi.json":
        return "application/json; charset=utf-8", latest_json(state, unit)
    if rest == "":
        return "text/html; charset=utf-8", list_page(state, unit)
    if rest.endswith(".jsonl") and state is not None and ID.match(rest[:-6]):
        stream = state / "giri" / rest
        return ("application/x-ndjson", stream.read_bytes()) if stream.is_file() else None
    body = attempt_page(state, rest, unit)
    return ("text/html; charset=utf-8", body) if body else None


# --- Home ----------------------------------------------------------------------


def home_section() -> str:
    """La sezione della home: le righe arrivano dallo script, il link resta comunque."""
    return f"""      <section class="pole ciclo autonomo">
        <h2><a href="{PREFIX}">{label("section")}</a></h2>
        <ol class="ciclo-righe" id="ciclo-righe">
          <li class="ciclo-vuoto">{html.escape(label("offline"))}</li>
        </ol>
        <script>
          (async () => {{
            const list = document.getElementById("ciclo-righe");
            try {{
              const response = await fetch("{PREFIX}ultimi.json", {{ cache: "no-store" }});
              if (!response.ok) return;
              const data = await response.json();
              list.replaceChildren();
              const item = (text) => {{
                const li = document.createElement("li");
                li.className = "ciclo-vuoto";
                li.textContent = text;
                list.append(li);
              }};
              if (data.testo) item(data.testo);
              for (const t of data.tentativi) {{
                const li = document.createElement("li");
                const dot = document.createElement("span");
                dot.className = "semaforo " + t.colore;
                li.append(dot);
                const text = t.ts.replace("T", " ").slice(0, 16) + " · " + t.esito;
                if (t.id) {{
                  const a = document.createElement("a");
                  a.href = "{PREFIX}" + t.id;
                  a.textContent = text;
                  li.append(a);
                }} else li.append(text);
                if (t.motivi.length) {{
                  const span = document.createElement("span");
                  span.className = "ciclo-motivi";
                  const motivi = " " + t.motivi.join(" · ");
                  const nuovo = t.task_cambiato;
                  const at = nuovo ? motivi.indexOf("→ " + nuovo.titolo) : -1;
                  if (at < 0) span.textContent = motivi;
                  else {{
                    const start = at + 2;
                    const task = document.createElement("a");
                    task.href = nuovo.href;
                    task.textContent = nuovo.titolo;
                    span.append(motivi.slice(0, start), task, motivi.slice(start + nuovo.titolo.length));
                  }}
                  li.append(span);
                }}
                list.append(li);
              }}
            }} catch (error) {{}}
          }})();
        </script>
      </section>"""
