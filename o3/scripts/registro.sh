#!/usr/bin/env bash
# Scrittura del registro di manutenzione: applica un filtro jq in place.
# Uso: registro.sh '<filtro jq>' [--arg nome valore ...]
# Il risultato deve restare un oggetto JSON, altrimenti il registro non cambia.
# MAINTENANCE_LOG consente prove su fixture.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
log="${MAINTENANCE_LOG:-$root/i1/manutenzione.json}"
if [[ $# -lt 1 ]]; then echo "uso: registro.sh '<filtro jq>' [opzioni jq]" >&2; exit 2; fi
filtro=$1
shift
tmp=$(mktemp "$log.XXXXXX")
trap 'rm -f "$tmp"' EXIT
jq --indent 2 "$@" "$filtro" "$log" >"$tmp"
jq -e 'type == "object"' "$tmp" >/dev/null || { echo "registro.sh: il risultato non è un oggetto, registro invariato" >&2; exit 3; }
mv "$tmp" "$log"
trap - EXIT
command -v prettier >/dev/null && prettier --write --log-level warn "$log"
git -C "$root" diff --stat -- "$log" 2>/dev/null || true
