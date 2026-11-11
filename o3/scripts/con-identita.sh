#!/usr/bin/env bash
# Explicit local identity for Nix, Home Manager and nixos-rebuild.
# Usage: con-identita.sh nix eval ... | home-manager switch ... |
#        sudo nixos-rebuild switch ...
# No implicit fallback to the public templates on a real host.
set -euo pipefail

identity_dir="${NIXOS_IDENTITY_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/nixos/identity}"
if [[ ! -d "$identity_dir" || ! -f "$identity_dir/default.nix" ]]; then
  echo "Identità locale assente: prepara $identity_dir (vedi o3/identity/README.md)." >&2
  exit 2
fi
identity_dir="$(cd "$identity_dir" && pwd -P)"
case "${1:-}" in
  nix | home-manager | nixos-rebuild) ;;
  sudo)
    [[ "${2:-}" == nixos-rebuild ]] || { echo "sudo ammesso solo per nixos-rebuild" >&2; exit 2; }
    ;;
  *) echo "uso: $0 nix|home-manager|nixos-rebuild|sudo nixos-rebuild <argomenti>" >&2; exit 2 ;;
esac
exec "$@" --override-input identity "path:$identity_dir" --no-write-lock-file
