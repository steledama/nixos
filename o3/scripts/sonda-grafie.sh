#!/usr/bin/env bash
# Sonda delle grafie dei permessi del giro: lancia `claude -p` con i settings
# fusi del giro (.git/lanciatore/settings.json, scritti dal lanciatore
# canonico) e le sue opzioni di permesso, una prova per forma di
# comando, e registra se l'harness concede o nega la grafia.
# Fuori dal giro: dentro il giro `claude -p` è negato e ogni prova costa API.
# Uso: o3/scripts/sonda-grafie.sh [--elenco] [--solo <nome>]
# Esito per riga in i1/grafie-permessi.jsonl (una tornata per versione).

set -euo pipefail

FLAKE_DIR="${FLAKE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$FLAKE_DIR"

SETTINGS="${SETTINGS:-$FLAKE_DIR/.git/lanciatore/settings.json}"
OUT="${OUT:-$FLAKE_DIR/i1/grafie-permessi.jsonl}"
BUDGET="${BUDGET:-0.5}"

# Forme campione: ogni comando è innocuo ed è composto solo da comandi in
# allow, così un diniego dipende dalla grafia e non dal contenuto.
# `git commit --dry-run` non scrive nella storia. `controllo-negato` è in
# deny: deve uscire negato, altrimenti la sonda non distingue i dinieghi.
nomi=(
  controllo-negato
  semplice
  graffe
  graffe-quotate
  graffe-quotate-virgola
  pipe-quotata
  gh-jq
  gh-jq-giro
  cd-solo
  cd-and
  and
  punto-e-virgola
  pipe
  redirezione
  sostituzione
  for
  heredoc-cat
  commit-m-ripetuti
  commit-heredoc-m
  commit-heredoc-F
  commit-heredoc-F-and
  log-trailer-quotato
  log-trailer-nudo
)
comandi=(
  "find o1 -maxdepth 0"
  "ls o1"
  "ls {o1,o2}"
  "jq -n '{a: 1}'"
  "jq -n '{a: 1, b: 2}'"
  "jq -n '[1, 2] | length'"
  "gh issue view 784 -R cyanfish/naps2 --json state --jq '.state'"
  "gh issue view 784 -R cyanfish/naps2 --json state,updatedAt,comments --jq '{state,updatedAt,n:(.comments|length)}'"
  "cd o1"
  "cd o1 && ls"
  "ls o1 && ls o2"
  "ls o1; ls o2"
  "ls o1 | wc -l"
  "ls o1 2>/dev/null"
  "wc -l \$(ls o1/plan.md)"
  "for d in o1 o2; do ls \"\$d\"; done"
  $'cat <<\'EOF\'\nprova\nEOF'
  "git commit --dry-run --allow-empty -m \"prova\" -m \"corpo\""
  $'git commit --dry-run --allow-empty -m "$(cat <<\'EOF\'\nprova\n\ncorpo\nEOF\n)"'
  $'git commit --dry-run --allow-empty -F - <<\'EOF\'\nprova\nEOF'
  $'git commit --dry-run --allow-empty -F - <<\'EOF\' && git log -1 --format=%h\nprova\nEOF'
  "git log -1 --format='%h %(trailers:key=Prossimo,valueonly)'"
  "git log -1 --format=%h%n%(trailers:key=Prossimo,valueonly)"
)

elenco=0
solo=""
while (($#)); do
  case $1 in
  --elenco) elenco=1 ;;
  --solo)
    solo=$2
    shift
    ;;
  *)
    echo "uso: $0 [--elenco] [--solo <nome>]" >&2
    exit 2
    ;;
  esac
  shift
done

if ((elenco)); then
  for i in "${!nomi[@]}"; do
    printf '%s\n%s\n\n' "== ${nomi[$i]}" "${comandi[$i]}"
  done
  exit 0
fi

[[ -f $SETTINGS ]] || {
  echo "settings del giro assenti: $SETTINGS" >&2
  exit 1
}

versione=$(claude --version | cut -d' ' -f1)
tornata=$(date -Iseconds)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Sonda grafie: Claude Code $versione, settings $SETTINGS"

for i in "${!nomi[@]}"; do
  nome=${nomi[$i]}
  cmd=${comandi[$i]}
  [[ -z $solo || $solo == "$nome" ]] || continue

  prompt="Usa lo strumento Bash per eseguire il comando fra le righe <<< e >>>, \
carattere per carattere e una sola volta. Non correggerlo, non spezzarlo, non \
usare altri strumenti. Se viene negato non riprovare in altra forma. Poi \
rispondi con una sola parola: ESEGUITO o NEGATO.
<<<
$cmd
>>>"

  traccia=$tmp/$nome.jsonl
  env -u CLAUDECODE claude -p "$prompt" \
    --settings "$SETTINGS" \
    --setting-sources project \
    --permission-mode dontAsk \
    --no-session-persistence \
    --output-format stream-json \
    --verbose \
    --max-turns 3 \
    --max-budget-usd "$BUDGET" \
    </dev/null >"$traccia" 2>/dev/null || true

  # Primo comando Bash tentato, dinieghi e costo dalla traccia.
  tentato=$(jq -rs '[.[] | select(.type == "assistant") | .message.content[]?
    | select(.type == "tool_use" and .name == "Bash") | .input.command][0] // ""' "$traccia")
  negato=$(jq -s --arg c "$cmd" '[.[] | select(.type == "result")
    | .permission_denials[]? | select(.tool_input.command == $c)] | length > 0' "$traccia")
  costo=$(jq -s '[.[] | select(.type == "result") | .total_cost_usd][0] // null' "$traccia")

  if [[ -z $tentato ]]; then
    esito=non-tentato
  elif [[ $tentato != "$cmd" ]]; then
    esito=riscritto
  elif [[ $negato == true ]]; then
    esito=negato
  else
    esito=concesso
  fi

  printf '%-20s %s\n' "$nome" "$esito"
  jq -cn --arg tornata "$tornata" --arg versione "$versione" --arg nome "$nome" \
    --arg comando "$cmd" --arg tentato "$tentato" --arg esito "$esito" \
    --argjson costo "$costo" \
    '{tornata: $tornata, claude_code: $versione, forma: $nome, comando: $comando,
      esito: $esito, costo_usd: $costo}
     + (if $esito == "riscritto" then {tentato: $tentato} else {} end)' >>"$OUT"
done

echo "Esiti aggiunti a $OUT"
