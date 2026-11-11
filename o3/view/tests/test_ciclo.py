"""Il ciclo autonomo nella vista: semaforo, stati senza tentativi, rotte di serve.py.

Lo stato è finto, scritto in una cartella temporanea con la forma del modulo
`cicli` di `nixos`. Eseguire con python3 -m unittest discover -s tests.
"""

import json
import sys
import tempfile
import unittest
from datetime import datetime
from pathlib import Path

BUILDERS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BUILDERS))

import ciclo

NOW = datetime.fromisoformat("2026-10-11T12:00:00+02:00")


def ident(char: str) -> str:
    return char * 32


class StateCase(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.state = self.root / "prova"
        (self.state / "giri").mkdir(parents=True)
        self.decide({"state": "manuale", "maxRuntime": "45min"})

    def tearDown(self):
        self.tmp.cleanup()

    def decide(self, decision: dict) -> None:
        (self.root / "decisioni.json").write_text(json.dumps({"prova": decision}))

    def attempt(self, char: str, ts: str, close: dict | None, result: str | None = None):
        rows = [{"evento": "partenza", "id": ident(char), "ts": ts}]
        if close is not None:
            rows.append({"evento": "chiusura", "id": ident(char), **close})
        with (self.state / "tentativi.jsonl").open("a") as out:
            out.writelines(json.dumps(row) + "\n" for row in rows)
        if result is not None:
            event = {"type": "result", "result": result}
            (self.state / "giri" / f"{ident(char)}.jsonl").write_text(json.dumps(event) + "\n")

    def colors(self) -> list[tuple[str, list[str]]]:
        view = ciclo.load(self.state, NOW)
        return [(a.color, a.reasons) for a in view["tentativi"]]


OK = {"esito": "riuscito", "commit": True, "push": True, "permission_denials": 0}


class Semaphore(StateCase):
    def test_green_needs_explicit_no_attention(self):
        self.attempt("a", "2026-10-11T05:30:00+02:00", OK, "Fatto.\n\n**Attenzione:** nessuna")
        self.assertEqual(self.colors(), [("verde", [])])

    def test_missing_attention_line_is_yellow(self):
        self.attempt("a", "2026-10-11T05:30:00+02:00", OK, "Fatto.")
        self.assertEqual(self.colors()[0][0], "giallo")

    def test_attention_items_and_denials_are_yellow(self):
        close = {**OK, "permission_denials": 2}
        self.attempt("a", "2026-10-11T05:30:00+02:00", close, "Attenzione: foto da decidere")
        color, reasons = self.colors()[0]
        self.assertEqual(color, "giallo")
        self.assertIn("foto da decidere", reasons)

    def test_agent_cannot_lower_a_block(self):
        close = {"esito": "arresto", "motivo": "tree-sporco"}
        self.attempt("a", "2026-10-11T05:30:00+02:00", close, "Attenzione: nessuna")
        self.assertEqual(self.colors(), [("rosso", ["tree-sporco"])])

    def test_commit_without_push_is_red(self):
        close = {**OK, "push": False}
        self.attempt("a", "2026-10-11T05:30:00+02:00", close, "Attenzione: nessuna")
        self.assertEqual(self.colors()[0][0], "rosso")

    def test_open_attempt_turns_red_past_max_runtime(self):
        self.attempt("a", "2026-10-11T11:50:00+02:00", None)
        self.attempt("b", "2026-10-11T09:00:00+02:00", None)
        self.assertEqual([c for c, _ in self.colors()], ["in-corso", "rosso"])

    def test_missed_daily_start_is_red(self):
        self.decide({"state": "timer", "cadence": "*-*-*", "time": "05:30"})
        self.attempt("a", "2026-10-10T05:30:00+02:00", OK, "Attenzione: nessuna")
        view = ciclo.load(self.state, NOW)
        self.assertTrue(view["tentativi"][0].missed)
        self.assertEqual(view["tentativi"][0].color, "rosso")

    def test_manual_state_has_no_missed_start(self):
        self.attempt("a", "2026-10-01T05:30:00+02:00", OK, "Attenzione: nessuna")
        self.assertFalse(any(a.missed for a in ciclo.load(self.state, NOW)["tentativi"]))


class WithoutAttempts(StateCase):
    def test_no_state_declared(self):
        self.assertEqual(ciclo.load(None, NOW)["stato"], "none")

    def test_external(self):
        self.decide({"state": "esterno", "note": "fuori nixos (Task Scheduler)"})
        self.assertEqual(ciclo.load(self.state, NOW)["stato"], "external")

    def test_never_started(self):
        self.assertEqual(ciclo.load(self.state, NOW)["stato"], "never")

    def test_declared_before_first_attempt(self):
        self.decide({"state": "manuale"})
        self.assertEqual(ciclo.load(self.root / "mai-partito", NOW)["stato"], "unreadable")
        (self.root / "decisioni.json").write_text(json.dumps({"mai-partito": {"state": "manuale"}}))
        self.assertEqual(ciclo.load(self.root / "mai-partito", NOW)["stato"], "never")

    def test_unreadable(self):
        self.assertEqual(ciclo.load(self.root / "assente", NOW)["stato"], "unreadable")

    def test_attempts_outside_the_unit(self):
        # Il repo dichiara giri (es. i1/giri): i tentativi stanno lì, le
        # decisioni accanto alla cartella dell'unità, alla chiave del repo.
        giri = self.root / "repo" / "i1" / "giri"
        (giri / "giri").mkdir(parents=True)
        self.decide({"state": "esterno", "note": "fuori nixos"})
        self.assertEqual(ciclo.load(giri, NOW, unit=self.state)["stato"], "external")
        self.decide({"state": "manuale"})
        self.assertEqual(ciclo.load(giri, NOW, unit=self.state)["stato"], "never")
        kind, _ = ciclo.respond("/_ciclo/ultimi.json", giri, self.state)
        self.assertTrue(kind.startswith("application/json"))


class Routes(StateCase):
    def test_latest_and_attempt_page(self):
        self.attempt("a", "2026-10-11T05:30:00+02:00", OK, "# Giro\n\n- uno\n\nAttenzione: nessuna")
        kind, body = ciclo.respond("/_ciclo/ultimi.json", self.state)
        self.assertTrue(kind.startswith("application/json"))
        self.assertEqual(json.loads(body)["tentativi"][0]["colore"], "verde")
        kind, body = ciclo.respond(f"/_ciclo/{ident('a')}", self.state)
        self.assertIn("<li>uno</li>", body.decode())

    def test_attempt_page_shows_subject_and_counts_denials(self):
        denied = [{"tool": "Bash", "input": "gh release list --repo x/y"}]
        close = {**OK, "oggetto": "fix: <uno>", "permission_denials": 1, "dinieghi": denied}
        self.attempt("b", "2026-10-11T05:30:00+02:00", close, "Attenzione: nessuna")
        page = ciclo.respond(f"/_ciclo/{ident('b')}", self.state)[1].decode()
        self.assertIn("<dt>oggetto</dt><dd>fix: &lt;uno&gt;</dd>", page)
        self.assertEqual(self.colors()[0][0], "giallo")

    def test_rejects_paths_outside_the_ids(self):
        self.assertIsNone(ciclo.respond("/_ciclo/../tentativi.jsonl", self.state))
        self.assertIsNone(ciclo.respond("/_ciclo/zzz.jsonl", self.state))

    def test_report_escapes_html(self):
        self.assertNotIn("<script>", ciclo.report_html("<script>x</script>"))


class NextTask(StateCase):
    """Il trailer `Prossimo:` letto dal commit del giro, contro il precedente."""

    def setUp(self):
        super().setUp()
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.run_git("init", "-q")
        self.saved, ciclo.REPO = ciclo.REPO, self.repo

    def tearDown(self):
        ciclo.REPO = self.saved
        super().tearDown()

    def run_git(self, *args: str) -> str:
        import os
        import subprocess

        names = ("GIT_AUTHOR_NAME", "GIT_AUTHOR_EMAIL", "GIT_COMMITTER_NAME", "GIT_COMMITTER_EMAIL")
        env = {**os.environ, **dict.fromkeys(names, "t")}
        command = ["git", "-C", str(self.repo), *args]
        result = subprocess.run(command, env=env, capture_output=True, text=True, check=True)
        return result.stdout.strip()

    def commit(self, trailers: str) -> str:
        self.run_git("commit", "-q", "--allow-empty", "-m", "giro", "-m", trailers)
        return self.run_git("rev-parse", "HEAD")

    def round(self, char: str, head: str) -> ciclo.Attempt:
        self.attempt(
            char, "2026-10-11T05:30:00+02:00", {**OK, "head_dopo": head}, "Attenzione: nessuna"
        )
        return next(a for a in ciclo.load(self.state, NOW)["tentativi"] if a.id == ident(char))

    def test_confirmed_task_stays_green(self):
        self.commit("Prossimo: Diagnosi orfani (confermato)")
        attempt = self.round("a", self.commit("Prossimo: Diagnosi orfani (confermato)"))
        self.assertEqual((attempt.color, attempt.next_task), ("verde", "Diagnosi orfani"))

    def test_unreadable_history_is_declared(self):
        ciclo.REPO = self.root / "senza-git"
        attempt = self.round("a", "0" * 40)
        self.assertEqual((attempt.color, attempt.reasons), ("giallo", [ciclo.label("no-history")]))

    def test_commit_not_yet_released_is_declared(self):
        self.commit("Prossimo: Diagnosi orfani (confermato)")
        attempt = self.round("a", "f" * 40)
        self.assertEqual(attempt.reasons, [ciclo.label("not-released")])

    def test_rounds_before_adoption_are_not_judged(self):
        attempt = self.round("a", self.commit("Autonomia: agente"))
        self.assertEqual((attempt.color, attempt.next_task), ("verde", None))

    def test_missing_trailer_is_yellow(self):
        self.commit("Prossimo: Diagnosi orfani (confermato)")
        attempt = self.round("a", self.commit("Autonomia: agente"))
        self.assertEqual((attempt.color, attempt.reasons), ("giallo", [ciclo.label("no-next")]))

    def test_declared_change_is_highlighted(self):
        self.commit("Prossimo: Diagnosi orfani (confermato)")
        attempt = self.round(
            "a", self.commit("Prossimo: Serie storica (cambiato, era Diagnosi orfani; smentita)")
        )
        self.assertEqual(attempt.color, "giallo")
        self.assertEqual(
            attempt.reasons, [f"{ciclo.label('changed')}: Diagnosi orfani → Serie storica"]
        )

    def test_undeclared_change_is_caught(self):
        self.commit("Prossimo: Diagnosi orfani (confermato)")
        self.run_git("commit", "-q", "--allow-empty", "-m", "sessione senza trailer")
        attempt = self.round("a", self.commit("Prossimo: Serie storica (confermato)"))
        self.assertIn(ciclo.label("undeclared"), attempt.reasons[0])
        page = ciclo.respond(f"/_ciclo/{ident('a')}", self.state)[1].decode()
        self.assertIn(
            f"Serie storica <small>({ciclo.label('previous')}: Diagnosi orfani)</small>", page
        )
        latest = json.loads(ciclo.respond("/_ciclo/ultimi.json", self.state)[1])
        self.assertNotIn("prossimo", latest["tentativi"][0])

    def write_plan(self, task: str, source: str) -> None:
        (self.repo / "o1").mkdir()
        (self.repo / "o1" / "plan.md").write_text(
            f"| Ciclo | Ob. | Task | Dip. |\n| --- | --- | --- | --- |\n"
            f"| dev | 1 | [{task}](../{source}) | — |\n",
            encoding="utf-8",
        )

    def latest_after_change(self) -> dict:
        self.commit("Prossimo: Diagnosi orfani (confermato)")
        self.round(
            "a", self.commit("Prossimo: Serie storica (cambiato, era Diagnosi orfani; smentita)")
        )
        return json.loads(ciclo.respond("/_ciclo/ultimi.json", self.state)[1])["tentativi"][0]

    def test_changed_priority_links_the_new_task(self):
        self.write_plan("Serie storica", "o2/serie-storica.md")
        self.assertEqual(
            self.latest_after_change()["task_cambiato"],
            {"titolo": "Serie storica", "href": "/o2/serie-storica.html"},
        )

    def test_task_out_of_the_plan_has_no_link(self):
        self.write_plan("Altro task", "o2/altro.md")
        self.assertNotIn("task_cambiato", self.latest_after_change())

    def test_confirmed_task_is_not_repeated_in_the_row(self):
        self.commit("Prossimo: Diagnosi orfani (confermato)")
        attempt = self.round("a", self.commit("Prossimo: Diagnosi orfani (confermato)"))
        self.assertNotIn("Diagnosi orfani", ciclo.row_html(attempt))


if __name__ == "__main__":
    unittest.main()
