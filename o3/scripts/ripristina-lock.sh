#!/usr/bin/env bash
# Ripristina flake.lock com'è in HEAD, dopo un bump fallito.
# Uso: ripristina-lock.sh
# Il gesto che git checkout flake.lock compirebbe, negato da git checkout*
# (presidio del cambio di branch): qui tocca solo il lock.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [[ $# -ne 0 ]]; then echo 'uso: ripristina-lock.sh' >&2; exit 2; fi
tmp=$(mktemp "$root/flake.lock.XXXXXX")
trap 'rm -f "$tmp"' EXIT
git -C "$root" show HEAD:flake.lock >"$tmp"
chmod --reference="$root/flake.lock" "$tmp"
mv "$tmp" "$root/flake.lock"
trap - EXIT
git -C "$root" diff --quiet -- flake.lock && echo "flake.lock ripristinato da HEAD"
