# ciclo-avvio <config.json>
#
# ExecStart of ciclo-<repo>: checks before Claude, then the round. Every
# stop leaves the reason in corrente.json, a line in the journal and its own
# exit code; ciclo-chiusura turns them into the closing line. Never merge,
# rebase or stash: a checkout to fix waits for the custodian.
#
# Exit codes: 0 round closed, 10 dirty tree, 11 unexpected branch or no upstream,
# 12 diverged from origin, 13 fetch or pull failed, 14 prompt or settings
# missing or invalid in the repo, 15 another session worked in the checkout
# during the round and ciclo-concorrenti blocked its commit, 20 Claude
# exited non-zero, 21 Claude reported an error, 75 another autonomous cycle holds
# the lock, 16 (probe only) the fence differs from the declared one.
#
# Probe mode (CICLO_SONDA=1, unit ciclo-<repo>-sonda): same unit fence,
# same read-only checks, then the fence is tested with test -r/-w, without
# writing anything; no fetch, no pull, never Claude. Outcome in sonde.jsonl,
# apart from the attempts.
#
# The round runs with stream-json: giri/<id>.jsonl keeps every event, so a
# command that dodged the fence (gog by absolute path, rclone on another
# remote) stays readable afterwards.
#
# Traces (tentativi.jsonl, ultimo.json, giri/): in the state directory, or
# in the checkout folder the repo declares as `giri` (method o3/ciclo-autonomo.md).
# The declared folder is used only after the pull and once git ignores it
# (else stop 14 giri-non-ignorati): the stops before that point, and those of
# ciclo-namespace, which runs outside the fence and never
# write in the checkout, stay in the state directory. The next attempt that
# passes the check moves them into the folder, in chronological order, before
# its own start line; the first one also migrates the old history. Lock,
# corrente.json, sonde.jsonl and the merged settings.json stay in the state.

cfg=$1
dir=${STATE_DIRECTORY:?ciclo-avvio gira dentro l unità ciclo-<repo>}
repo=$(jq -r .repo "$cfg")
branch=$(jq -r .branch "$cfg")
settings=$(jq -r .settings "$cfg")
prompt=$(jq -r .prompt "$cfg")
budget=$(jq -r .maxBudgetUsd "$cfg")
claude=$(jq -r .claude "$cfg")
giri=$(jq -r '.giri // ""' "$cfg")
id=${INVOCATION_ID:-manuale-$(date +%s)}
corrente=$dir/corrente.json
sonda=${CICLO_SONDA:-}
[[ -z $sonda ]] || corrente=$dir/sonda.json
tracce=$dir

# Same unit cannot run twice under systemd; the lock also covers a run of the
# script outside it. Taken before corrente.json, which belongs to the holder.
exec 9>"$dir/lock"
if ! flock -n 9; then
  echo "ciclo $repo: arresto: un altro ciclo tiene il lock" >&2
  exit 75
fi

record() {
  jq "$@" "$corrente" >"$corrente.tmp" && mv "$corrente.tmp" "$corrente"
}

# Probe outcome: one line in sonde.jsonl, the attempt's files stay untouched.
sonda_close() {
  record --arg ts "$(date -Is)" --arg esito "$1" '.ts_chiusura = $ts | .esito = $esito'
  jq -c '{evento: "sonda"} + .' "$corrente" >>"$dir/sonde.jsonl"
  echo "ciclo $repo: sonda $(jq -r '"\(.esito)\(if .motivo then " (" + .motivo + ")" else "" end)"' "$corrente")"
  rm -f "$corrente"
}

# The repo's settings with the unit's hostSettings on top: what --settings gets.
merge_settings() {
  jq -s '.[0] * .[1]' "$settings" <(jq .hostSettings "$cfg")
}

# The start line goes where the attempt's traces go, decided after the pull:
# a stop before that point writes it in the state directory.
partenza() {
  [[ -z $sonda && $(jq -r '.partenza_scritta // false' "$corrente") != true ]] || return 0
  record --arg t "$tracce" '.partenza_scritta = true | .tracce = $t'
  jq -c '{evento: "partenza", id, repo, host, ts: .ts_partenza, head: .head_prima, branch}' \
    "$corrente" >>"$tracce/tentativi.jsonl"
}

# Readiness of the declared folder: ignored by git, a real directory of the
# checkout (no symlink on the way out of it).
giri_ignorati() {
  git check-ignore -q "$giri/x" || return 1
  mkdir -p "$checkout/$giri"
  [[ $(realpath -e "$checkout/$giri") == "$checkout/$giri" ]]
}

# Moves into the folder what the state directory gathered since the last
# move: the early stops, and the first time the whole old history.
raccogli() {
  local t=$checkout/$giri
  if [[ -f $dir/tentativi.jsonl ]]; then
    mv "$dir/tentativi.jsonl" "$dir/tentativi.da-spostare"
    cat "$dir/tentativi.da-spostare" >>"$t/tentativi.jsonl"
    rm -f "$dir/tentativi.da-spostare"
  fi
  [[ ! -f $dir/ultimo.json ]] || mv "$dir/ultimo.json" "$t/ultimo.json"
  if [[ -d $dir/giri ]]; then
    mkdir -p "$t/giri"
    find "$dir/giri" -maxdepth 1 -name '*.jsonl' -exec mv -n -t "$t/giri" {} +
    rmdir "$dir/giri" 2>/dev/null || true
  fi
}

stop() {
  partenza
  record --arg m "$2" '.motivo = $m'
  echo "ciclo $repo: arresto: $2" >&2
  [[ -z $sonda ]] || sonda_close arresto
  exit "$1"
}

jq -n --arg id "$id" --arg repo "$repo" --arg host "$(</proc/sys/kernel/hostname)" \
  --arg ts "$(date -Is)" --arg head "$(git rev-parse HEAD)" \
  --arg branch "$(git symbolic-ref --short -q HEAD || echo '(detached)')" \
  '{id: $id, repo: $repo, host: $host, ts_partenza: $ts, head_prima: $head, branch: $branch}' >"$corrente"

checkout=$(pwd -P)
[[ $(jq -r .branch "$corrente") == "$branch" ]] || stop 11 branch-inatteso

# Open sessions are not checked here: an idle one is harmless, and one that
# works during the round is caught at commit time (code 15, below).
[[ -z $(git status --porcelain) ]] || stop 10 checkout-sporco

if [[ -n $sonda ]]; then
  [[ -f $prompt ]] || stop 14 prompt-mancante
  [[ -f $settings ]] || stop 14 settings-mancante
  [[ -z $giri ]] || git check-ignore -q "$giri/x" || stop 14 giri-non-ignorati
  merged=$(merge_settings) || stop 14 settings-invalide
  record --argjson s "$merged" '.attribution = $s.attribution'
  recinto='[]'
  check() {
    local reale
    if [[ ! -e $1 ]]; then
      reale=assente
    elif [[ ! -r $1 ]]; then
      reale=inaccessibile
    elif [[ -w $1 ]]; then
      reale=scrivibile
    else
      reale=sola-lettura
    fi
    recinto=$(jq -c --arg p "$1" --arg a "$2" --arg r "$reale" \
      '. + [{path: $p, atteso: $a, reale: $r, ok: ($a == $r)}]' <<<"$recinto")
  }
  # Relative to the home, or absolute for a path outside it (/srv/bi).
  inhome() { [[ $1 == /* ]] && echo "$1" || echo "$HOME/$1"; }
  if [[ $(jq -r '.homeWritable' "$cfg") == true ]]; then
    check "$HOME" scrivibile
  else
    check "$HOME" sola-lettura
  fi
  check "$checkout" scrivibile
  check "$dir" scrivibile
  while read -r rel; do check "$(inhome "$rel")" scrivibile; done < <(jq -r '.readWritePaths[]' "$cfg")
  while read -r rel; do check "$HOME/$rel" sola-lettura; done < <(jq -r '.readOnlyPaths[]' "$cfg")
  while read -r rel; do check "$(inhome "$rel")" inaccessibile; done < <(jq -r '.inaccessiblePaths[]' "$cfg")
  record --argjson r "$recinto" '.recinto = $r'
  jq -e 'all(.recinto[]; .ok)' "$corrente" >/dev/null || stop 16 recinto-violato
  sonda_close superata
  exit 0
fi
git fetch --quiet origin || stop 13 fetch-fallito
git rev-parse -q --verify '@{u}' >/dev/null || stop 11 upstream-mancante

# Read-only paths of the unit inside the checkout (the round's own prompt and
# permissions): a pull that changes them would fail halfway on the fence and
# leave the tree dirty, so it waits for a pull outside the unit.
mapfile -t fissi < <(jq -r '.checkout as $c | .readOnlyPaths[] | select(startswith($c + "/")) | ltrimstr($c + "/")' "$cfg")

read -r ahead behind < <(git rev-list --left-right --count "HEAD...@{u}")
if ((ahead > 0 && behind > 0)); then
  stop 12 branch-divergente
elif ((behind > 0)); then
  ((${#fissi[@]} == 0)) || git diff --quiet HEAD '@{u}' -- "${fissi[@]}" || stop 13 pull-in-sola-lettura
  git pull --ff-only --quiet || stop 13 pull-fallito
  record --arg head "$(git rev-parse HEAD)" '.head_prima = $head'
fi
# Ahead only: the round pushes, as the repo decides.

if [[ -n $giri ]]; then
  giri_ignorati || stop 14 giri-non-ignorati
  tracce=$checkout/$giri
  raccogli
fi
partenza

[[ -f $prompt ]] || stop 14 prompt-mancante
[[ -f $settings ]] || stop 14 settings-mancante
merge_settings >"$dir/settings.json" || stop 14 settings-invalide

mkdir -p "$tracce/giri"
giro=$tracce/giri/$id.jsonl
record --arg giro "$giro" '.giro = $giro'
echo "ciclo $repo: giro avviato, head $(git rev-parse --short HEAD)"

# ciclo-concorrenti (PreToolUse hook on the round's git commit) compares the
# other sessions' transcripts with this marker, and leaves concorrenti.json
# when it blocks a commit.
rm -f "$dir/concorrenti.json"
touch "$dir/inizio-giro"

rc=0
"$claude" -p "$(cat "$prompt")" \
  --settings "$dir/settings.json" \
  --setting-sources project \
  --permission-mode dontAsk \
  --no-session-persistence \
  --output-format stream-json \
  --verbose \
  --max-budget-usd "$budget" \
  </dev/null >"$giro" || rc=$?
record --argjson rc "$rc" '.claude_exit = $rc'

# Keep the last 60 rounds: raw outputs stay local, never published.
find "$tracce/giri" -name '*.jsonl' -printf '%T@ %p\n' | sort -rn | tail -n +61 | cut -d' ' -f2- | xargs -r rm -f

rm -f "$dir/inizio-giro"
if [[ -f $dir/concorrenti.json ]]; then
  record --slurpfile c "$dir/concorrenti.json" '.sessioni_concorrenti = $c[0].sessioni'
  rm -f "$dir/concorrenti.json"
  stop 15 sessione-concorrente
fi

((rc == 0)) || stop 20 claude-uscita-non-zero
# The final event of type result carries is_error, denials, cost, duration.
esito=$(jq -c 'select(.type == "result")' "$giro" 2>/dev/null | tail -n 1 || true)
[[ -n $esito && $(jq -r .is_error <<<"$esito") == false ]] || stop 21 claude-errore
echo "ciclo $repo: giro chiuso"
