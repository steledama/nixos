# ciclo-concorrenti
#
# PreToolUse hook of the round (hostSettings), on Bash: before a git commit
# it looks for another session that worked in the checkout while the round
# ran, and blocks the commit with exit 2. The check sits at commit time, not
# before the round (custodian, 2026-11-10): a Claude or Codex session left
# open and idle is harmless and must not stop the cycle, one that wrote
# during the round could have its changes swept into the round's commit.
#
# "Worked during the round" = called a tool after the marker that
# ciclo-avvio touches right before launching Claude:
# - Claude: ~/.claude/projects/<checkout with every non-alphanumeric
#   character turned into ->/*.jsonl (the round runs with
#   --no-session-persistence and leaves none of its own);
# - Codex: ~/.codex/sessions/**/rollout-*.jsonl whose session_meta cwd is in
#   the checkout (Codex sessions are threads of one app-server daemon, /proc
#   does not see their cwd).
# Both are readable from inside the fence, where /proc/<pid>/cwd is denied.
#
# A block also writes concorrenti.json in the state directory: ciclo-avvio
# reads it after Claude and stops with code 15 sessione-concorrente, so the
# closing line says why the round left its work uncommitted.

input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
# git commit, also as git -C <dir> commit or after other commands. A false
# match (git log --grep commit) only matters when a session is found.
grep -Eq '(^|[^[:alnum:]_-])git([[:space:]][^;&|]*)?[[:space:]]commit([[:space:]]|$)' <<<"$cmd" || exit 0

dir=${STATE_DIRECTORY:-}
marker=$dir/inizio-giro
[[ -n $dir && -f $marker ]] || exit 0

checkout=$(git -C "${CLAUDE_PROJECT_DIR:-$PWD}" rev-parse --show-toplevel 2>/dev/null) || exit 0
checkout=$(realpath "$checkout")

# Same event criterion as method 18a9f5a (lavora_dopo / _chiamata).
# The mtime prefilter below is not sufficient: replies and tool outputs
# also update the transcript of the session that launched the round.
lavora_dopo() {
  python3 - "$1" "$marker" <<'PY'
import json
import sys
from datetime import datetime
from pathlib import Path

file, marker = map(Path, sys.argv[1:])
try:
    dopo = marker.stat().st_mtime
    with file.open("rb") as stream:
        stream.seek(max(0, file.stat().st_size - 4 * 1024 * 1024))
        lines = stream.read().decode("utf-8", errors="replace").splitlines()
except OSError:
    sys.exit(1)
for line in reversed(lines):
    try:
        event = json.loads(line)
        moment = datetime.fromisoformat(event["timestamp"]).timestamp()
    except (ValueError, KeyError, TypeError, AttributeError):
        continue
    if moment <= dopo:
        break
    message = event.get("message") or {}
    content = message.get("content") if isinstance(message, dict) else None
    payload = event.get("payload") or {}
    kind = payload.get("type") if isinstance(payload, dict) else None
    if (
        event.get("type") == "assistant"
        and isinstance(content, list)
        and any(isinstance(part, dict) and part.get("type") == "tool_use" for part in content)
    ) or (
        event.get("type") == "response_item"
        and isinstance(kind, str) and kind.endswith("_call")
    ):
        sys.exit(0)
sys.exit(1)
PY
}

trovate=()
progetti=$HOME/.claude/projects
enc=${checkout//[^[:alnum:]]/-}
if [[ -d $progetti ]]; then
  while IFS= read -r -d '' f; do
    lavora_dopo "$f" || continue
    trovate+=("claude:$f")
  done < <(find "$progetti" -mindepth 2 -maxdepth 2 -name '*.jsonl' -newer "$marker" \
    \( -path "$progetti/$enc/*" -o -path "$progetti/$enc-*/*" \) -print0)
fi

sessions=${CODEX_HOME:-$HOME/.codex}/sessions
if [[ -d $sessions ]]; then
  while IFS= read -r -d '' f; do
    cwd=$(head -n 1 "$f" | jq -r 'select(.type == "session_meta") | .payload.cwd // empty' 2>/dev/null) || continue
    [[ -n $cwd && ($cwd == "$checkout" || $cwd == "$checkout"/*) ]] || continue
    lavora_dopo "$f" || continue
    trovate+=("codex:$f")
  done < <(find "$sessions" -name 'rollout-*.jsonl' -newer "$marker" -print0)
fi

((${#trovate[@]} > 0)) || exit 0

printf '%s\n' "${trovate[@]}" | jq -R . | jq -s -c --arg ts "$(date -Is)" '{ts: $ts, sessioni: .}' \
  >"$dir/concorrenti.json"
{
  echo "ciclo: commit bloccato, un'altra sessione ha lavorato nel checkout durante il giro:"
  printf '  %s\n' "${trovate[@]}"
  echo "Non committare e non riprovare: lascia il working tree com'è, chiudi il giro e"
  echo "dichiaralo nella riga Attenzione: del resoconto (sessione-concorrente)."
  echo "Il custode riconcilia le modifiche."
} >&2
exit 2
