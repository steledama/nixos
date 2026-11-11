# ciclo-fetch <config.json> <seconds per checkout>
#
# ExecStartPre=+ of ciclo-<repo>: fetches origin in the
# checkouts the repo declares as fetch, outside the unit's namespace, where
# their .git/ is writable (inside the home is read-only: method's round of
# 2026-10-20 got "impossibile aprire .git/FETCH_HEAD"). Only git fetch, never
# the working tree: those checkouts may host another session. The round
# reads the outcome in fetch.json of the state directory, one entry per
# checkout with esito, ts, origin/main and ultimo_riuscito, the ts of the
# last successful fetch carried over from the previous fetch.json, so a
# failed fetch still tells the age of the origin read. A failed fetch never
# stops the unit: each one is bounded by the timeout, and the unit's start
# timeout is sized on it (cicli.nix); the round declares the limit instead.

cfg=$1
limite=${2:-15}
dir=${STATE_DIRECTORY:?ciclo-fetch gira dentro l unità ciclo-<repo>}
repo=$(jq -r .repo "$cfg")
precedente=$dir/fetch.json

voci=()
while IFS= read -r rel; do
  [[ -n $rel ]] || continue
  co=$HOME/$rel
  ts=$(date -Is)
  if [[ ! -d $co/.git ]]; then
    esito=checkout-assente
  elif timeout "$limite" git -C "$co" fetch --quiet origin; then
    esito=riuscito
  else
    esito=fallito
  fi
  if [[ $esito == riuscito ]]; then
    ultimo=$ts
  else
    # The previous entry's ultimo_riuscito, or its ts if it predates the field.
    ultimo=$(jq -r --arg c "$rel" \
      '[.fetch[]? | select(.checkout == $c) | .ultimo_riuscito // (if .esito == "riuscito" then .ts else null end)][0] // ""' \
      "$precedente" 2>/dev/null) || ultimo=
  fi
  head=$(git -C "$co" rev-parse --short origin/main 2>/dev/null) || head=
  [[ $esito == riuscito ]] || echo "ciclo $repo: fetch di $rel: $esito" >&2
  voci+=("$(jq -n -c --arg c "$rel" --arg e "$esito" --arg ts "$ts" --arg h "$head" --arg u "$ultimo" \
    '{checkout: $c, esito: $e, ts: $ts, origin_main: (if $h == "" then null else $h end), ultimo_riuscito: (if $u == "" then null else $u end)}')")
done < <(jq -r '.fetch[]' "$cfg")

printf '%s\n' "${voci[@]}" | jq -s --arg id "${INVOCATION_ID:-manuale}" '{id: $id, fetch: .}' \
  >"$dir/fetch.json.tmp" && mv "$dir/fetch.json.tmp" "$dir/fetch.json"
exit 0
