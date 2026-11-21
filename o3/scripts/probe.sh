#!/usr/bin/env bash
# Valuta le probe: della legenda del plan, senza il modello (method/plan.md,
# «Risveglio»). Vocabolario chiuso, mai un comando preso dal plan:
#   github <owner>/<repo>#<n> closed    stato della issue
#   nixpkgs <attributo> >= <versione>   versione su nixos-unstable
#   registro <ramo> dopo <AAAA-MM-GG>   data del ramo in i1/manutenzione.json
# Uso: probe.sh [indice...]   (es. w1 w3 o 1 3; senza argomenti: tutte le w con probe:)
# Output TSV: indice, tipo, condizione, esito (vero/falso/errore), dettaglio.
# Sola lettura. FLAKE_DIR e MAINTENANCE_LOG consentono prove su fixture.
set -euo pipefail
root="${FLAKE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
log="${MAINTENANCE_LOG:-$root/i1/manutenzione.json}"
# L'indice si scrive w1 o 1: la forma nuda vale come w.
args=()
for arg in "$@"; do
    [[ "$arg" =~ ^[0-9]+$ ]] && arg="w$arg"
    [[ "$arg" =~ ^w[0-9]+$ ]] || { echo "indice non valido: $arg" >&2; exit 2; }
    args+=("$arg")
done
set -- "${args[@]}"
# Stessa lettura della legenda di maintenance-due.sh: indice -> chiosa su una riga.
legend=$(awk '
    function flush() { if (k != "") { gsub(/ +/, " ", t); print k "\t" t }; k = "" }
    /^- `[wp][0-9]+!?`/ { flush(); match($0, /`[wp][0-9]+/)
        k = substr($0, RSTART + 1, RLENGTH - 1); t = $0; next }
    /^  / && k != "" { t = t " " $0; next }
    { flush() }
    END { flush() }' "$root/o1/plan.md")

err=$(mktemp)
trap 'rm -f "$err"' EXIT
printf 'indice\ttipo\tcondizione\tesito\tdettaglio\n'
while IFS=$'\t' read -r index text; do
    [[ "$index" == w* && "$text" == *probe:* ]] || continue
    if [[ $# -gt 0 && " $* " != *" $index "* ]]; then continue; fi
    probe=${text#*probe: }
    probe=${probe%%;*}
    probe=${probe%% (*}
    kind=${probe%% *}
    result=errore detail=-
    if [[ "$probe" =~ ^github\ ([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)#([0-9]+)\ closed$ ]]; then
        if json=$(gh issue view "${BASH_REMATCH[2]}" -R "${BASH_REMATCH[1]}" --json state 2>"$err"); then
            detail=$(jq -r '.state' <<< "$json")
            if [[ "$detail" == CLOSED ]]; then result=vero; else result=falso; fi
        else detail="gh: $(tr '\t\n' '  ' < "$err")"; fi
    elif [[ "$probe" =~ ^nixpkgs\ ([A-Za-z0-9_-]+)\ \>=\ ([0-9][0-9A-Za-z.-]*)$ ]]; then
        want=${BASH_REMATCH[2]}
        if have=$(nix eval --raw "github:NixOS/nixpkgs/nixos-unstable#${BASH_REMATCH[1]}.version" 2>"$err"); then
            detail=$have
            if [[ $(printf '%s\n%s\n' "$want" "$have" | sort -V | head -n1) == "$want" ]]; then
                result=vero
            else result=falso; fi
        else detail="nix: $(tr '\t\n' '  ' < "$err")"; fi
    elif [[ "$probe" =~ ^registro\ ([a-z][a-z.-]*)\ dopo\ ([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]]; then
        since=${BASH_REMATCH[2]}
        detail=$(jq -r --arg p "${BASH_REMATCH[1]}" 'getpath($p | split(".")).data // "-"' "$log")
        if [[ "$detail" == - ]]; then result=falso
        elif [[ "$detail" > "$since" ]]; then result=vero
        else result=falso; fi
    else
        detail='tipo sconosciuto'
    fi
    printf '%s\t%s\t%s\t%s\t%s\n' "$index" "$kind" "$probe" "$result" "${detail:0:200}"
done <<< "$legend"
