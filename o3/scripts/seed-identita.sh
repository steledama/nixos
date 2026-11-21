#!/usr/bin/env bash
# Note dell'identità locale nel seed, la cassaforte Bitwarden del custode.
# Uso: seed-identita.sh verifica|aggiorna
#   verifica  confronta byte per byte le note casa/identity/… con i file locali
#   aggiorna  riscrive le note dai file locali, poi le rilegge
# Lo lancia il custode in un terminale proprio, mai in una sessione con un
# agente: stampa solo nomi ed esiti, mai valori, e blocca la cassaforte alla
# fine. Riusa BW_SESSION se già aperta, altrimenti chiede la master password.
# Uscita: 0 tutte conformi, 1 almeno una nota assente o diversa, 2 uso o file
# locali mancanti, 3 bw o jq assenti.
# NIXOS_IDENTITY_DIR e BW (il comando bw) consentono prove su fixture.
set -euo pipefail

uso() { echo "uso: seed-identita.sh verifica|aggiorna" >&2; exit 2; }
[[ $# -eq 1 ]] || uso
modo=$1
case "$modo" in verifica | aggiorna) ;; *) uso ;; esac

identity_dir="${NIXOS_IDENTITY_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/nixos/identity}"
privacy="$(dirname "$identity_dir")/privacy.json"
nomi=(casa/identity/default.nix casa/identity/home.nix casa/identity/work.nix casa/identity/privacy.json)
file=("$identity_dir/default.nix" "$identity_dir/home.nix" "$identity_dir/work.nix" "$privacy")
for f in "${file[@]}"; do
  [[ -f "$f" ]] || { echo "file locale assente: $f" >&2; exit 2; }
done

bw="${BW:-bw}"
command -v "$bw" >/dev/null || { echo "comando bw assente" >&2; exit 3; }
command -v jq >/dev/null || { echo "comando jq assente" >&2; exit 3; }

if [[ -z "${BW_SESSION:-}" ]]; then
  BW_SESSION=$("$bw" unlock --raw)
  export BW_SESSION
fi
trap '"$bw" lock >/dev/null 2>&1 || true' EXIT
"$bw" sync >/dev/null

voce_id() { # nome esatto -> id, solo se la voce è unica
  local id
  id=$("$bw" list items --search "$1" | jq -r --arg n "$1" '.[] | select(.name == $n) | .id')
  [[ -n "$id" && $(wc -l <<<"$id") -eq 1 ]] || return 1
  printf '%s' "$id"
}

conforme() { # id file
  "$bw" get item "$1" | jq -j .notes | cmp -s - "$2"
}

esito=0
for i in "${!nomi[@]}"; do
  nome=${nomi[$i]}
  f=${file[$i]}
  if ! id=$(voce_id "$nome"); then
    echo "$nome assente o non univoca" >&2
    esito=1
    continue
  fi
  if [[ "$modo" == aggiorna ]] && ! conforme "$id" "$f"; then
    "$bw" get item "$id" | jq --rawfile n "$f" '.notes = $n' | "$bw" encode |
      "$bw" edit item "$id" >/dev/null
  fi
  if conforme "$id" "$f"; then
    echo "$nome conforme"
  else
    echo "$nome NON conforme" >&2
    esito=1
  fi
done
exit "$esito"
