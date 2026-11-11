# ciclo-recinto <attese.json>
#
# Runs inside the transient unit the probe of a launcher cycle starts with
# the same fence as the agent's (cicli.nix, recinto): tests every declared
# path with test -e/-r/-w, writes nothing, prints one JSON array on stdout
# and exits 16 when a path differs from what the fence declares. A missing
# path counts as ok only where the declaration is optional: inside the
# checkout, .git/lanciatore is born with the first round.

attese=$1
risultati=()
while IFS=$'\t' read -r path atteso opzionale; do
  if [[ ! -e $path ]]; then
    reale=assente
  elif [[ ! -r $path ]]; then
    reale=inaccessibile
  elif [[ -w $path ]]; then
    reale=scrivibile
  else
    reale=sola-lettura
  fi
  ok=false
  if [[ $reale == "$atteso" || ($reale == assente && $opzionale == true) ]]; then
    ok=true
  fi
  risultati+=("$(jq -n -c --arg p "$path" --arg a "$atteso" --arg r "$reale" --argjson ok "$ok" \
    '{path: $p, atteso: $a, reale: $r, ok: $ok}')")
done < <(jq -r '.[] | [.path, .atteso, (.opzionale | tostring)] | @tsv' "$attese")

esito=$(printf '%s\n' "${risultati[@]}" | jq -s -c .)
echo "$esito"
jq -e 'all(.[]; .ok)' <<<"$esito" >/dev/null || exit 16
