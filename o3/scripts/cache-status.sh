#!/usr/bin/env bash
# Stato di uno store path nelle cache binarie indicate, interrogando il
# narinfo via HTTP. Uso: cache-status.sh [-v] <store-path> <substituter>...
#
# Stampa su stdout un solo simbolo aggregato:
#   ✓  presente in almeno una cache
#   ✗  assente in tutte (ogni cache ha risposto 404)
#   !  nessuna cache lo ha, e almeno una ha negato l'accesso (401/403)
#   ?  disponibilità non verificata (errore di rete, altra risposta,
#      schema non HTTP, path non valido, nessuna cache)
# Con -v stampa anche su stderr una riga "<cache> <esito>" per cache, con
# esito presente|assente|accesso-negato|non-verificata.
# La presenza vale per quel path oggi: non dice nulla di un path futuro.
set -uo pipefail

verbose=0
if [[ "${1:-}" == "-v" ]]; then
    verbose=1
    shift
fi
store_path="${1:-}"
shift || true

base="${store_path##*/}"
hash="${base%%-*}"
if [[ "$store_path" != /nix/store/* || ! "$hash" =~ ^[0-9a-z]{32}$ || "$base" != "$hash"-* ]]; then
    echo "?"
    exit 0
fi

presente=0
negato=0
incerto=0
for cache in "$@"; do
    cache="${cache%/}"
    case "$cache" in
        http://* | https://*)
            code="$(curl -s -o /dev/null -w '%{http_code}' --max-time "${CACHE_TIMEOUT:-15}" "$cache/$hash.narinfo" 2>/dev/null)" || code="000"
            ;;
        *) code="schema" ;;
    esac
    case "$code" in
        200) esito="presente"; presente=1 ;;
        404) esito="assente" ;;
        401 | 403) esito="accesso-negato"; negato=1 ;;
        *) esito="non-verificata"; incerto=1 ;;
    esac
    ((verbose)) && echo "$cache $esito" >&2
done

if ((presente)); then
    echo "✓"
elif ((negato)); then
    echo "!"
elif ((incerto)) || (($# == 0)); then
    echo "?"
else
    echo "✗"
fi
