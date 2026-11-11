# ciclo-namespace <config.json>
#
# ExecStopPost=+ of ciclo-<repo>, before ciclo-chiusura. When systemd cannot
# set up the unit's namespace (226/NAMESPACE: a readWritePaths entry on a
# Drive mount answering I/O error, 2026-10-14), ciclo-avvio never starts and
# ciclo-chiusura fails at the same step, so the attempt would live only in
# the journal. Outside the namespace this script writes the closing line in
# their place. It acts only on 226 and reads nothing the round can write:
# no git in the checkout (a hook or core.fsmonitor set by a round would run
# here unfenced), no corrente.json.

cfg=$1
[[ ${EXIT_STATUS:-} == 226 ]] || exit 0
dir=${STATE_DIRECTORY:?ciclo-namespace gira dentro l unità ciclo-<repo>}
repo=$(jq -r .repo "$cfg")

jq -c -n \
  --arg id "${INVOCATION_ID:-manuale}" --arg repo "$repo" --arg ts "$(date -Is)" \
  --arg result "${SERVICE_RESULT:-}" --arg code "${EXIT_CODE:-}" '
  {
    evento: "chiusura", id: $id, repo: $repo, ts: $ts,
    esito: "errore", motivo: "namespace",
    service_result: $result, exit_code: $code, exit_status: "226",
    head_prima: null, head_dopo: null, commit: false, push: false,
    tree_sporco_dopo: null, claude_exit: null, giro: null
  }' >"$dir/chiusura.tmp"

cat "$dir/chiusura.tmp" >>"$dir/tentativi.jsonl"
mv "$dir/chiusura.tmp" "$dir/ultimo.json"
echo "ciclo $repo: errore (namespace), unità non avviata, motivo nel journal"
