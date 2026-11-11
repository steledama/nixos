#!/usr/bin/env bash
# Deriva di configurazione: il sistema che il flake costruisce oggi per un host
# è diverso da quello attivo?
# Uso: ./system-drift.sh [host] [revisione] [sistema]
#   host       default: hostname
#   revisione  default: nixos-version --configuration-revision (solo sull'host
#              stesso); da deck per gli altri host la riga «revisione:» di
#              `remoto stato <host>`
#   sistema    toplevel attivo; default: /run/current-system (solo sull'host
#              stesso); da deck la riga «sistema:» di `remoto stato <host>`
#
# La revisione attiva (o3/hosts/default.nix) dice da quale codice pubblico
# viene il sistema: <rev> o <rev>-dirty, oppure nar:<narHash> quando il build
# è passato da con-identita.sh a checkout pulito. Il narHash si riconduce al
# contenuto di un commit confrontandolo con quello degli ultimi commit;
# commit con lo stesso albero non si distinguono tramite narHash.
#
# Il verdetto confronta output, non revisioni: HEAD valutato con l'identità
# locale di oggi e con la revisione forzata a quella attiva deve dare
# esattamente il toplevel attivo. Così contano codice, input e identità
# locale, e non conta la sola etichetta della revisione. Senza il toplevel
# (host remoto senza terzo argomento) resta il confronto dei drv fra la
# revisione attiva e HEAD, che non vede l'identità. Solo valutazione,
# nessuna build né sudo.
#
# Con deriva elenca, come spiegazione, i commit sui path che la configurazione
# di sistema legge e i pin nixpkgs di sistema cambiati: sono candidati, perché
# o3/modules/system è importato in modo selettivo dagli host.

set -euo pipefail

FLAKE_DIR="${FLAKE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$FLAKE_DIR"

HOST="${1:-$(hostname)}"
NAR_LIMIT="${DRIFT_NAR_LIMIT:-40}"

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
    SISTEMA="${3:-}"
elif [[ "$HOST" == "$(hostname)" ]]; then
    REV="$(nixos-version --configuration-revision 2>/dev/null || true)"
    SISTEMA="$(readlink -f /run/current-system 2>/dev/null || true)"
else
    echo "per $HOST servono revisione e sistema (da remoto stato $HOST)" >&2
    exit 2
fi

HEAD_REV="$(git rev-parse HEAD)"
echo "host: $HOST"
echo "revisione attiva: ${REV:-assente}"
echo "sistema attivo: ${SISTEMA:-non indicato}"
echo "HEAD: ${HEAD_REV:0:7}"

non_misurabile() {
    echo "verdetto: non misurabile ($1)"
    exit 0
}

# La revisione entra in un'espressione Nix: solo forme note.
if [[ -n "$REV" && ! "$REV" =~ ^([0-9a-f]{40}(-dirty)?|nar:sha256-[A-Za-z0-9+/]+=*|dirty)$ ]]; then
    non_misurabile "revisione in forma sconosciuta"
fi
if [[ -n "$SISTEMA" && ! "$SISTEMA" =~ ^/nix/store/[0-9a-z]{32}-[^/]+$ ]]; then
    non_misurabile "toplevel attivo in forma sconosciuta"
fi

nar_di() {
    nix flake metadata --json "git+file://$FLAKE_DIR?rev=$1" 2>/dev/null | jq -r '.locked.narHash // empty'
}

# Provenienza: COMMIT (se risolto) e STATO pulita|modificata|sconosciuta.
COMMIT=""
STATO="sconosciuta"
case "$REV" in
    *-dirty)
        COMMIT="$(git rev-parse --verify --quiet "${REV%-dirty}^{commit}" || true)"
        STATO="modificata"
        echo "provenienza: albero modificato su ${REV:0:7}"
        ;;
    nar:*)
        nar="${REV#nar:}"
        while read -r candidato; do
            if [[ "$(nar_di "$candidato")" == "$nar" ]]; then
                COMMIT="$candidato"
                STATO="pulita"
                break
            fi
        done < <(git rev-list --max-count="$NAR_LIMIT" HEAD)
        if [[ -n "$COMMIT" ]]; then
            echo "provenienza: contenuto del commit ${COMMIT:0:7} (narHash corrispondente; commit d'origine non univoco)"
        else
            echo "provenienza: sconosciuta (nessuna corrispondenza verificata fra gli ultimi $NAR_LIMIT commit; possibile commit fuori finestra o metadati non disponibili)"
        fi
        ;;
    "" | dirty)
        echo "provenienza: sconosciuta (revisione ${REV:-assente}, build precedente alla correzione)"
        ;;
    *)
        if COMMIT="$(git rev-parse --verify --quiet "${REV}^{commit}")"; then
            STATO="pulita"
            echo "provenienza: commit ${COMMIT:0:7}"
        else
            COMMIT=""
            echo "provenienza: commit sconosciuto a questo checkout"
        fi
        ;;
esac

candidati() {
    local base="$1"
    local percorsi=(
        flake.nix
        o3/hosts/default.nix
        "o3/hosts/$HOST"
        o3/modules/system
        o3/identity
        o3/patches
        o3/presentations.nix
    )
    if [[ "$base" == "$HEAD_REV" ]]; then
        echo "commit candidati: nessuno (stesso commit di HEAD)"
        return
    fi
    echo "commit candidati:"
    git log --format='  %h %s' "$base..HEAD" -- "${percorsi[@]}"
    for p in "${pin[@]}"; do
        prima="$(git show "$base:flake.lock" | jq -r --arg p "$p" '.nodes[$p].locked.rev // "assente"')"
        ora="$(git show HEAD:flake.lock | jq -r --arg p "$p" '.nodes[$p].locked.rev // "assente"')"
        if [[ "$prima" != "$ora" ]]; then
            echo "pin cambiato: $p ${prima:0:7} -> ${ora:0:7}"
        fi
    done
}

# Valuta un attributo del toplevel di <commit> con la revisione forzata.
valuta() {
    local commit="$1" revisione="$2" attributo="$3"
    "$FLAKE_DIR/o3/scripts/con-identita.sh" nix eval --raw \
        "git+file://$FLAKE_DIR?rev=$commit#nixosConfigurations.$HOST" \
        --apply "c: (c.extendModules { modules = [ { system.configurationRevision = c.pkgs.lib.mkForce \"$revisione\"; } ]; }).config.system.build.toplevel.$attributo" 2>/dev/null
}

if [[ -z "$SISTEMA" ]]; then
    # Host remoto senza toplevel: confronto dei drv, identità non confrontata.
    [[ "$STATO" == pulita ]] || non_misurabile "senza toplevel attivo serve una provenienza pulita"
    echo "nota: senza toplevel attivo l'identità locale non è confrontata"
    if [[ "$COMMIT" == "$HEAD_REV" ]]; then
        echo "verdetto: allineato"
        exit 0
    fi
    prima="$(valuta "$COMMIT" fissa drvPath)" || non_misurabile "valutazione fallita: identità locale assente?"
    ora="$(valuta "$HEAD_REV" fissa drvPath)" || non_misurabile "valutazione fallita: identità locale assente?"
    if [[ "$prima" == "$ora" ]]; then
        echo "verdetto: allineato (commit successivi senza effetto sul sistema di $HOST)"
        exit 0
    fi
    echo "verdetto: deriva (rebuild pendente)"
    candidati "$COMMIT"
    exit 0
fi

atteso="$(valuta "$HEAD_REV" "$REV" outPath)" || non_misurabile "valutazione di HEAD fallita: identità locale assente?"
if [[ "$atteso" == "$SISTEMA" ]]; then
    case "$STATO" in
        pulita)
            if [[ "$COMMIT" == "$HEAD_REV" ]]; then
                echo "verdetto: allineato"
            else
                echo "verdetto: allineato (commit successivi senza effetto sul sistema di $HOST)"
            fi
            ;;
        *) echo "verdetto: allineato (il sistema coincide con HEAD; provenienza $STATO)" ;;
    esac
    exit 0
fi

case "$STATO" in
    pulita)
        dal_commit="$(valuta "$COMMIT" "$REV" outPath)" || non_misurabile "valutazione di ${COMMIT:0:7} fallita: identità locale assente?"
        if [[ "$dal_commit" == "$SISTEMA" ]]; then
            echo "verdetto: deriva (rebuild pendente)"
        else
            echo "verdetto: deriva (il sistema attivo non coincide con ${COMMIT:0:7} valutato con l'identità locale di oggi: identità locale o input cambiati dopo il build)"
        fi
        candidati "$COMMIT"
        ;;
    modificata)
        echo "verdetto: deriva (sistema costruito da un albero modificato; rebuild da checkout pulito)"
        if [[ -n "$COMMIT" ]]; then
            candidati "$COMMIT"
        fi
        ;;
    *)
        echo "verdetto: deriva (provenienza sconosciuta; rebuild da checkout pulito)"
        ;;
esac
