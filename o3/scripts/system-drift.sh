#!/usr/bin/env bash
# Deriva di configurazione: il sistema che il flake costruisce oggi per un host
# è diverso da quello attivo?
# Uso: ./system-drift.sh [host] [revisione]
#   host       default: hostname
#   revisione  default: nixos-version --configuration-revision (solo sull'host
#              stesso); da deck per gli altri host si passa quella letta da
#              `remoto stato <host>` (riga «revisione:»)
#
# Il toplevel grezzo non si confronta: system.configurationRevision = self.rev
# (o3/hosts/default.nix) lo fa cambiare a ogni commit. Lo script valuta il
# toplevel alla revisione attiva e a HEAD con quell'opzione fissata
# (extendModules), e confronta i due drv: uguali = nessuna deriva, qualunque
# cosa sia cambiata altrove nel repo. Solo valutazione, nessuna build né sudo;
# circa dieci secondi per revisione.
#
# Con deriva elenca, come spiegazione, i commit sui path che la configurazione
# di sistema legge e i pin nixpkgs di sistema cambiati: sono candidati, perché
# o3/modules/system è importato in modo selettivo dagli host.

set -euo pipefail

FLAKE_DIR="${FLAKE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$FLAKE_DIR"

HOST="${1:-$(hostname)}"

case "$HOST" in
    deck | neve) pin=(nixpkgs) ;;
    game) pin=(nixpkgs nixpkgs-whisper) ;;
    *)
        echo "host sconosciuto: $HOST" >&2
        exit 2
        ;;
esac

if [[ $# -ge 2 ]]; then
    REV="$2"
elif [[ "$HOST" == "$(hostname)" ]]; then
    REV="$(nixos-version --configuration-revision 2>/dev/null || true)"
else
    echo "per $HOST serve la revisione (da remoto stato $HOST)" >&2
    exit 2
fi

HEAD_REV="$(git rev-parse HEAD)"
echo "host: $HOST"
echo "revisione attiva: ${REV:-assente}"
echo "HEAD: ${HEAD_REV:0:7}"

if [[ -z "$REV" || "$REV" == dirty ]] ||
    ! REV="$(git rev-parse --verify --quiet "${REV}^{commit}")"; then
    echo "verdetto: non misurabile (sistema costruito da albero sporco o revisione sconosciuta a questo checkout)"
    exit 0
fi

if [[ "$REV" == "$HEAD_REV" ]]; then
    echo "verdetto: allineato"
    exit 0
fi

# shellcheck disable=SC2016
fissa='c: (c.extendModules { modules = [ { system.configurationRevision = c.pkgs.lib.mkForce "fissa"; } ]; }).config.system.build.toplevel.drvPath'
drv() {
    "$FLAKE_DIR/o3/scripts/con-identita.sh" nix eval --raw "git+file://$FLAKE_DIR?rev=$1#nixosConfigurations.$HOST" --apply "$fissa"
}

if [[ "$(drv "$REV")" == "$(drv "$HEAD_REV")" ]]; then
    echo "verdetto: allineato (commit successivi senza effetto sul sistema di $HOST)"
    exit 0
fi

percorsi=(
    flake.nix
    o3/hosts/default.nix
    "o3/hosts/$HOST"
    o3/modules/system
    o3/identity
    o3/patches
    o3/presentations.nix
)

echo "verdetto: deriva (rebuild pendente)"
echo "commit candidati:"
git log --format='  %h %s' "$REV..HEAD" -- "${percorsi[@]}"
for p in "${pin[@]}"; do
    prima="$(git show "$REV:flake.lock" | jq -r --arg p "$p" '.nodes[$p].locked.rev // "assente"')"
    ora="$(git show HEAD:flake.lock | jq -r --arg p "$p" '.nodes[$p].locked.rev // "assente"')"
    if [[ "$prima" != "$ora" ]]; then
        echo "pin cambiato: $p ${prima:0:7} -> ${ora:0:7}"
    fi
done
