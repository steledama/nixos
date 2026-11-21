#!/usr/bin/env bash
# Deriva della home: la home che il flake costruisce a HEAD per un host è
# diversa da quella attiva?
# Uso: ./home-drift.sh [host] [generazione]
#   host         default: hostname
#   generazione  default: la generazione home-manager attiva (solo sull'host
#                stesso); da deck per gli altri host si passa la riga «home:»
#                di `remoto stato <host>`, o il solo path che contiene
#
# La generazione è l'activationPackage della configurazione: valutare il suo
# outPath a HEAD e confrontarlo col path attivo dice se lo switch è pendente,
# a differenza dell'albero inviato da `remoto` (cambia a ogni commit, anche di
# soli testi) e di home.json (registra i rev degli input, non i moduli). Solo
# valutazione, nessuna build; circa dieci secondi.

set -euo pipefail

FLAKE_DIR="${FLAKE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$FLAKE_DIR"

HOST="${1:-$(hostname)}"

case "$HOST" in
    deck | neve | game) utente=stele ;;
    *)
        echo "host sconosciuto: $HOST" >&2
        exit 2
        ;;
esac

if [[ $# -ge 2 ]]; then
    ATTIVA="$(grep -o '/nix/store/[^ ]*-home-manager-generation' <<<"$2" || true)"
elif [[ "$HOST" == "$(hostname)" ]]; then
    ATTIVA="$(readlink -f ~/.local/state/nix/profiles/home-manager 2>/dev/null || true)"
else
    echo "per $HOST serve la generazione (riga home: di remoto stato $HOST)" >&2
    exit 2
fi

HEAD_REV="$(git rev-parse HEAD)"
echo "host: $HOST"
echo "generazione attiva: ${ATTIVA:-assente}"
echo "HEAD: ${HEAD_REV:0:7}"

if [[ -z "$ATTIVA" ]]; then
    echo "verdetto: non misurabile (generazione attiva non letta)"
    exit 0
fi

ATTESA="$("$FLAKE_DIR/o3/scripts/con-identita.sh" nix eval --raw "git+file://$FLAKE_DIR?rev=$HEAD_REV#homeConfigurations.\"$utente@$HOST\".activationPackage.outPath")"
echo "generazione di HEAD: $ATTESA"

if [[ "$ATTIVA" == "$ATTESA" ]]; then
    echo "verdetto: allineato"
    exit 0
fi
echo "verdetto: deriva (switch pendente)"
