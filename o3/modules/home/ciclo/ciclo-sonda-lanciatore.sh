# ciclo-sonda-lanciatore <config.json>
#
# ExecStart of ciclo-<repo>-sonda for a repo whose cycle runs the canonical
# launcher (cicli.nix, lanciatore = true). Two parts, never the agent:
#
# - `lanciatore.py --controlli`, outside any namespace like the round's
#   launcher: lock-free read-only checks (fermo, prima, sessions, branch,
#   clean tree, prompt and permissions), all of them, first stop's code;
# - ciclo-recinto in a transient unit with the agent's own fence, bound to
#   this probe: the declared paths tested from inside.
#
# Outcome in sonde.jsonl of the state directory, one line per probe. Codes:
# the first stop of the checks, else 16 when the fence differs or its unit
# did not start, else 0. An open session (15) with a sound fence skips the
# probe with code 0, as the old ExecCondition did, so it does not dirty
# systemctl --user --failed (custodian, 2026-10-16).

cfg=$1
dir=${STATE_DIRECTORY:?ciclo-sonda-lanciatore gira dentro l unità ciclo-<repo>-sonda}
repo=$(jq -r .repo "$cfg")
python=$(jq -r .python "$cfg")
lanciatore=$(jq -r .lanciatore "$cfg")
mapfile -t recinto < <(jq -r '.sondaRecinto[]' "$cfg")
ts=$(date -Is)

rc=0
controlli=$("$python" "$lanciatore" --controlli 2>&1) || rc=$?
rrc=0
fence=$("${recinto[@]}" 2>/dev/null) || rrc=$?
jq -e 'type == "array"' <<<"$fence" >/dev/null 2>&1 || fence=null

if ((rc != 0 && rc != 15)); then
  esito=arresto motivo=controlli-$rc codice=$rc
elif [[ $fence == null ]]; then
  esito=arresto motivo=recinto-non-avviato-$rrc codice=16
elif ((rrc != 0)); then
  esito=arresto motivo=recinto-violato codice=16
elif ((rc == 15)); then
  esito=saltata motivo=sessione-aperta codice=0
else
  esito=superata motivo='' codice=0
fi

jq -n -c --arg id "${INVOCATION_ID:-manuale}" --arg repo "$repo" \
  --arg host "$(</proc/sys/kernel/hostname)" --arg ts "$ts" --arg chiusura "$(date -Is)" \
  --arg esito "$esito" --arg motivo "$motivo" --argjson rc "$rc" --arg uscita "$controlli" \
  --argjson recinto "$fence" '
  {
    evento: "sonda", id: $id, repo: $repo, host: $host,
    ts_partenza: $ts, ts_chiusura: $chiusura, esito: $esito,
    motivo: (if $motivo == "" then null else $motivo end),
    controlli: {codice: $rc, uscita: $uscita}, recinto: $recinto
  }' >>"$dir/sonde.jsonl"

echo "ciclo $repo: sonda $esito${motivo:+ ($motivo)}"
[[ -z $controlli ]] || printf '%s\n' "$controlli"
exit "$codice"
