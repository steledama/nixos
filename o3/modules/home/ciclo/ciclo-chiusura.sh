# ciclo-chiusura <config.json>
#
# ExecStopPost of ciclo-<repo>: systemd runs it after every end, timeout
# and kill included, with SERVICE_RESULT, EXIT_CODE and EXIT_STATUS. It joins
# them with corrente.json and the round's final result event into the closing line of
# tentativi.jsonl, and copies it to ultimo.json. It observes, never acts.
# Both go where ciclo-avvio put the attempt's traces (corrente.json, .tracce):
# the state directory when the attempt stopped before choosing.

cfg=$1
dir=${STATE_DIRECTORY:?ciclo-chiusura gira dentro l unità ciclo-<repo>}
repo=$(jq -r .repo "$cfg")
id=${INVOCATION_ID:-manuale}
corrente=$dir/corrente.json

# corrente.json of another attempt (lock held elsewhere) is not ours.
cur='{}'
if [[ -f $corrente ]] && [[ $(jq -r .id "$corrente") == "$id" ]]; then
  cur=$(cat "$corrente")
fi

head_dopo=$(git rev-parse HEAD 2>/dev/null || echo "")
upstream=$(git rev-parse '@{u}' 2>/dev/null || echo "")
sporco=false
[[ -z $(git status --porcelain 2>/dev/null) ]] || sporco=true

tracce=$(jq -r --arg d "$dir" '.tracce // $d' <<<"$cur")

giro=$(jq -r '.giro // ""' <<<"$cur")
claude='{}'
if [[ -n $giro && -s $giro ]]; then
  # stream-json: one event per line; a timeout leaves no result event.
  esito=$(jq -c 'select(.type == "result")' "$giro" 2>/dev/null | tail -n 1 || true)
  if [[ -n $esito ]]; then
    # dinieghi: what was denied, readable without opening the closed giri/.
    claude=$(jq -c '{is_error, permission_denials: ((.permission_denials // []) | length),
      dinieghi: [(.permission_denials // [])[] | {tool: .tool_name,
        input: ((.tool_input.command // .tool_input.file_path // .tool_input.url
          // (.tool_input | tostring)) | tostring | .[0:1000])}],
      costo_usd: .total_cost_usd, turni: .num_turns, durata_ms: .duration_ms}' <<<"$esito")
  fi
fi

# oggetto: subject of the round's commit, null when HEAD did not move.
head_prima=$(jq -r '.head_prima // ""' <<<"$cur")
oggetto=null
if [[ -n $head_prima && -n $head_dopo && $head_prima != "$head_dopo" ]]; then
  oggetto=$(git log -1 --format=%s HEAD 2>/dev/null | jq -R . || echo null)
fi

jq -c -n \
  --arg id "$id" --arg repo "$repo" --arg ts "$(date -Is)" \
  --arg result "${SERVICE_RESULT:-}" --arg code "${EXIT_CODE:-}" --arg status "${EXIT_STATUS:-}" \
  --arg head_dopo "$head_dopo" --arg upstream "$upstream" --argjson sporco "$sporco" \
  --argjson cur "$cur" --argjson claude "$claude" --argjson oggetto "${oggetto:-null}" '
  ($cur.head_prima // null) as $prima |
  {
    evento: "chiusura", id: $id, repo: $repo, ts: $ts,
    esito: (if $result == "timeout" then "timeout"
            elif $cur.motivo != null then "arresto"
            elif $result == "success" and $code == "exited" and $status == "0"
              and $cur.claude_exit == 0 and $claude.is_error == false then "riuscito"
            elif $result == "success" then "arresto"
            else "errore" end),
    motivo: ($cur.motivo // (if $status == "75" then "lock"
              elif $result == "success" and ($code != "exited" or $status != "0"
                or $cur.claude_exit != 0 or $claude.is_error != false)
              then "interrotto" else null end)),
    service_result: $result, exit_code: $code, exit_status: $status,
    head_prima: $prima, head_dopo: $head_dopo,
    commit: ($prima != null and $head_dopo != "" and $prima != $head_dopo),
    oggetto: $oggetto,
    push: ($head_dopo != "" and $head_dopo == $upstream),
    tree_sporco_dopo: $sporco,
    claude_exit: ($cur.claude_exit // null),
    giro: ($cur.giro // null)
  }
  + (if $cur.sessioni_concorrenti then {sessioni_concorrenti: $cur.sessioni_concorrenti} else {} end)
  + $claude' >"$dir/chiusura.tmp"

cat "$dir/chiusura.tmp" >>"$tracce/tentativi.jsonl"
mv "$dir/chiusura.tmp" "$tracce/ultimo.json"
[[ $(jq -r .id <<<"$cur") != "$id" ]] || rm -f "$corrente"
echo "ciclo $repo: $(jq -r '"\(.esito)\(if .motivo then " (" + .motivo + ")" else "" end), commit \(.commit), push \(.push)"' "$tracce/ultimo.json")"
