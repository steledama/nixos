#!/usr/bin/env bash
# Sola lettura: scadenze del registro, non autorizzazioni né esecuzione.
# Uso: maintenance-due.sh [host]
# FLAKE_DIR, MAINTENANCE_LOG e MAINTENANCE_NOW consentono prove su fixture.
# Output TSV: tutte le voci, con applicabilità all'host esplicita.
set -euo pipefail
root="${FLAKE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
host="${1:-$(hostname)}"
if [[ $# -gt 1 ]]; then echo 'uso: maintenance-due.sh [host]' >&2; exit 2; fi
case "$host" in deck|neve|game) ;; *) echo "host sconosciuto: $host" >&2; exit 2 ;; esac
now=$(date -d "${MAINTENANCE_NOW:-now}" +%s)
today=$(date -d "@$now" +%F)
# Mezzanotte UTC per contare date civili senza errori nei cambi d'ora.
today_days=$(( $(date -u -d "$today" +%s) / 86400 ))
log="${MAINTENANCE_LOG:-$root/i1/manutenzione.json}"
if [[ -e "$log" ]]; then data=$(cat "$log"); else data='{}'; fi
# Legenda delle attese: indice (w1, p2) -> chiosa su una riga, senza il `!`.
legend=$(awk '
    function flush() { if (k != "") { gsub(/ +/, " ", t); print k "\t" t }; k = "" }
    /^- `[wp][0-9]+!?`/ { flush(); match($0, /`[wp][0-9]+/)
        k = substr($0, RSTART + 1, RLENGTH - 1); t = $0; next }
    /^  / && k != "" { t = t " " $0; next }
    { flush() }
    END { flush() }' "$root/o1/plan.md" | jq -Rn '[inputs | split("\t") | {(.[0]): .[1]}] | add // {}')
# Materializza anche le voci note senza storico e i task world con probe: nel plan.
rows=$(jq -ce --rawfile plan "$root/o1/plan.md" --argjson legend "$legend" '
  if type != "object" then error("il registro deve essere un oggetto") else . end
  | . as $log
  | def row($p; $hosts; $mode; $cad):
      ($log | getpath($p)) as $v
      | {percorso: ($p|join(".")), hosts: $hosts, modo: $mode,
         voce: ($v // {}), cadenza: $cad};
    [ ("ia", "home-manager", "casa") as $b
      | row([$b]; (if $b == "casa" then ["deck","neve","game"] else [] end);
          "calendario"; $log[$b].cadenza_giorni) ]
    + [row(["casa","gogcli"]; ["deck"]; "calendario";
        $log.casa.cadenza_giorni)]
    + [ "casa" as $b
      | (($log[$b].host_specifico // {})
          + {neve: ($log.casa.host_specifico.neve // {}),
             game: ($log.casa.host_specifico.game // {})})
      | to_entries[] | .key as $h | .value as $v
      | (if ($v|has("pacchetti_host")) or $h == "game" or $h == "neve"
          then row([$b,"host_specifico",$h,"pacchetti_host"]; [$h]; "revisione"; null)
            + {revisione: $log[$b].nixpkgs_rev} else empty end),
        ((($v.pacchetti_dedicati // {})
            + (if $h == "game" then
                 {"whisper-cpp": ($v.pacchetti_dedicati["whisper-cpp"] // {})}
               else {} end)) | to_entries[]
          | row([$b,"host_specifico",$h,"pacchetti_dedicati",.key]; [$h];
              "calendario"; .value.cadenza_giorni)) ]
    + [ ($plan | split("\n")[] | split("|")
        | map(gsub("^\\s+|\\s+$"; ""))
        | select(length == 6) | select(.[4] | test("^w[0-9]+!?$"))
        | select(($legend[.[4] | sub("!$"; "")] // "") | test("probe:")) | .[3]) as $title
      | row(["world",$title]; []; "calendario"; $log.world[$title].cadenza_giorni) ]
  | .[]
' <<< "$data")
printf 'percorso\tapplicabile\tdata\tora\tcadenza_giorni\tgiorni\tstato\tfreschezza\tapplicato_su\trevisione_valutata\trevisione_gruppo\n'
while IFS= read -r row; do
    fields=$(jq -r --arg host "$host" '[.percorso,
        (if (.hosts|length) == 0 or (.hosts|index($host)) != null
         then "sì" else "no" end), .voce.data // "-", .voce.ora // "-",
        .cadenza // "-", .modo,
        (if (.voce|has("applicato_su")) then
            if (.voce.applicato_su|index($host)) != null then "presente" else "assente" end
         else "non registrato" end),
        .voce.nixpkgs_rev_valutato // "-", .revisione // "-"] | @tsv' <<< "$row")
    IFS=$'\t' read -r path applicable day hour cadence mode applied evaluated revision <<< "$fields"
    days=- freshness=- state='mai controllato'
    if [[ "$day" != - ]]; then
        [[ "$day" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { echo "$path: data non valida" >&2; exit 2; }
        stamp=$(date -u -d "$day" +%s)
        days=$((today_days - stamp / 86400))
        if (( days < 0 )); then echo "$path: data futura" >&2; exit 2; fi
    fi
    if [[ "$mode" == revisione ]]; then
        cadence=-
        if [[ "$revision" == - ]]; then state='revisione assente'
        elif [[ "$evaluated" == "$revision" ]]; then state='non dovuto'
        else state='dovuto su diagnosi/allineamento'; fi
    elif [[ "$day" != - ]]; then
        [[ "$cadence" =~ ^[1-9][0-9]*$ ]] || { echo "$path: cadenza mancante o non valida" >&2; exit 2; }
        if (( days < cadence )); then state='non dovuto'; freshness=anticipato
        elif (( days == cadence )); then state=dovuto; freshness='in linea'
        else state=dovuto; freshness='in ritardo'; fi
    fi
    # Ora locale del registro; la differenza è in secondi, anche a mezzanotte.
    if [[ "$day" != - && "$hour" != - ]]; then
        [[ "$hour" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]] || { echo "$path: ora non valida" >&2; exit 2; }
        age=$((now - $(date -d "$day $hour" +%s)))
        if (( age < 0 )); then echo "$path: timestamp futuro" >&2; exit 2; fi
        if (( age < 600 )); then state=debounce; fi
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$path" "$applicable" "$day" "$hour" "$cadence" "$days" "$state" "$freshness" "$applied" "$evaluated" "$revision"
done <<< "$rows"
# Voci orfane: world.<titolo> senza una riga w con probe: nel plan, e
# promosso che nomina un task non più nel plan. Il dato è vecchio: va tolto.
jq -r --rawfile plan "$root/o1/plan.md" --argjson legend "$legend" '
    ($plan | split("\n") | map(split("|") | map(gsub("^\\s+|\\s+$"; ""))
        | select(length == 6))) as $rows
    | ($rows | map(.[3]) | map(select(. != "Task" and (test("^-+$") | not)))) as $titles
    | ($rows | map(select(.[4] | test("^w[0-9]+!?$"))
        | select(($legend[.[4] | sub("!$"; "")] // "") | test("probe:")) | .[3])) as $probed
    | ((.world // {}) | to_entries[] | select(.key as $t | $probed | index($t) | not)
        | ["orfano.world." + .key, .value.data // "-", .value.ora // "-",
           "voce orfana"]),
      (paths(strings) as $p | select($p[-1] == "promosso")
        | getpath($p) as $t | select($titles | index($t) | not)
        | ["orfano." + ($p | map(tostring) | join(".")), "-", "-",
           "promosso orfano"])
    | "\(.[0])\tsì\t\(.[1])\t\(.[2])\t-\t-\t\(.[3])\t-\tnon registrato\t-\t-"
' <<< "$data"
