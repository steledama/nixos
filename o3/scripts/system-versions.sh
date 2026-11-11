#!/usr/bin/env bash
# Script per confrontare versioni attuali vs disponibili su nixpkgs unstable.
# Verifica anche la disponibilita' nella cache binaria.
# Uso: ./system-versions.sh

set -euo pipefail

FLAKE_DIR="${FLAKE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$FLAKE_DIR"

# Auto-detect hostname (può essere sovrascritto con HOST=game ./system-versions.sh)
HOST="${HOST:-$(hostname)}"

host_input() {
    local host="$1"
    case "$host" in
        deck|game|neve) echo "nixpkgs" ;;
        *) echo "sconosciuto" ;;
    esac
}

HOST_INPUT="$(host_input "$HOST")"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${BOLD}Confronto versioni: Attuale vs Nixpkgs Unstable${NC}"
echo -e "${BLUE}Flake directory: $FLAKE_DIR${NC}"
echo -e "${BLUE}Host: $HOST${NC}"
echo -e "${BLUE}Input host: $HOST_INPUT${NC}"
echo ""

get_reference_pkg() {
    local pkg="$1"
    echo "$pkg"
}

# Funzione per ottenere versione dal flake locale
get_local_version() {
    local pkg="$1"
    nix eval --raw ".#nixosConfigurations.${HOST}.pkgs.${pkg}.version" 2>/dev/null || echo "N/A"
}

# Funzione per ottenere versione da nixpkgs unstable (ultimo commit).
get_unstable_version() {
    local pkg="$1"
    local ref_pkg
    ref_pkg=$(get_reference_pkg "$pkg")
    nix eval --raw "github:NixOS/nixpkgs/nixos-unstable#${ref_pkg}.version" 2>/dev/null || echo "N/A"
}

# Funzione per verificare se il pacchetto di riferimento è nella cache binaria
# Ritorna: "✓" se in cache, "✗" se richiede compilazione, "?" se errore
check_cache() {
    local pkg="$1"
    local pkg_path
    local ref_pkg
    ref_pkg=$(get_reference_pkg "$pkg")
    if ! pkg_path=$(nix eval --raw "github:NixOS/nixpkgs/nixos-unstable#${ref_pkg}.outPath" 2>/dev/null); then
        # Alcuni pacchetti host-specifici (es. llama-cpp) trascinano CUDA
        # unfree: la versione è leggibile, ma outPath richiede allow-unfree.
        if ! pkg_path=$(NIXPKGS_ALLOW_UNFREE=1 nix eval --impure --raw "github:NixOS/nixpkgs/nixos-unstable#${ref_pkg}.outPath" 2>/dev/null); then
            echo "?"
            return
        fi
    fi
    if nix path-info --store https://cache.nixos.org "$pkg_path" &>/dev/null; then
        echo "✓"
    else
        echo "✗"
    fi
}

# Funzione per ottenere la dimensione del closure del pacchetto (in bytes)
get_closure_size() {
    local pkg="$1"
    local size
    size=$(nix path-info -S ".#nixosConfigurations.${HOST}.pkgs.${pkg}" 2>/dev/null | awk '{sum += $2} END {print sum+0}')
    if [[ -z "$size" ]]; then
        echo "0"
    else
        echo "$size"
    fi
}

# Funzione per formattare la dimensione in formato leggibile
format_size() {
    local bytes="$1"
    if [[ "$bytes" == "0" || -z "$bytes" ]]; then
        echo "N/A"
        return
    fi
    if (( bytes >= 1073741824 )); then
        awk "BEGIN {printf \"%.1f GB\", $bytes / 1073741824}"
    elif (( bytes >= 1048576 )); then
        awk "BEGIN {printf \"%.1f MB\", $bytes / 1048576}"
    elif (( bytes >= 1024 )); then
        awk "BEGIN {printf \"%.1f KB\", $bytes / 1024}"
    else
        echo "${bytes} B"
    fi
}

# Header tabella
echo -e "${BOLD}┌───────────┬──────────┬──────────────────┬───────────────────┬───┬───┐${NC}"
printf "${BOLD}│ %-9s │ %8s │ %-16s │ %-17s │ S │ C │${NC}\n" "Pacchetto" "Peso" "Versione Attuale" "Versione Unstable"
echo -e "${BOLD}├───────────┼──────────┼──────────────────┼───────────────────┼───┼───┤${NC}"

# Lista pacchetti da controllare (escluso kernel, gestito separatamente)
declare -A PACKAGES=(
    ["niri"]="Niri"
    ["noctalia"]="Noctalia"
    ["foot"]="Foot"
    ["zed-editor"]="Zed"
    ["chromium"]="Chromium"
    ["mpv"]="mpv"
    ["imv"]="imv"
    ["zathura"]="Zathura"
    ["abiword"]="AbiWord"
    ["gnumeric"]="Gnumeric"
    ["nodejs_24"]="Node.js"
    ["fish"]="Fish"
    ["helix"]="Helix"
    ["git"]="Git"
    ["docker"]="Docker"
    ["syncthing"]="Syncthing"
    ["thunar"]="Thunar"
    ["llama-cpp"]="llama.cpp"
    ["whisper-cpp"]="Whisper"
    ["naps2"]="NAPS2"
    ["steam"]="Steam"
    ["heroic"]="Heroic"
    ["mangohud"]="MangoHud"
)

# Ordine di visualizzazione statico (escluso kernel).
# E' l'ordine oggi usato dopo l'ordinamento per peso decrescente, cosi'
# i risultati possono essere stampati subito senza attendere la fine.
ORDERED_KEYS=(
    "chromium"
    "zed-editor"
    "noctalia"
    "mpv"
    "docker"
    "niri"
    "gnumeric"
    "zathura"
    "git"
    "abiword"
    "thunar"
    "fish"
    "helix"
    "nodejs_24"
    "imv"
    "foot"
    "syncthing"
)

case "$HOST" in
    game)
        # Capability host-specifica: stack gaming (steam/heroic/mangohud,
        # gaming.nix, importato solo da game) - pacchetti host-esclusivi ma
        # a cadenza normale, non compile-pesante.
        ORDERED_KEYS+=(
            "steam"
            "heroic"
            "mangohud"
        )
        # Capability host-specifica: workstation GPU con CUDA.
        # Questi pacchetti possono trascinare build lunghe anche quando la
        # lista comune non mostra rischi evidenti.
        ORDERED_KEYS+=(
            "llama-cpp"
            "whisper-cpp"
        )
        ;;
    neve)
        # Capability host-specifica: desktop con scanner.
        # NAPS2 è patchato localmente via overlay per l'OCR su Linux.
        ORDERED_KEYS+=(
            "naps2"
        )
        ;;
esac

# === KERNEL (sempre primo, senza controllo peso) ===
total=${#ORDERED_KEYS[@]}
printf "\r${YELLOW}[1/%d] Controllando: Kernel              ${NC}" "$((total + 1))" >&2
kernel_local=$(get_local_version "linuxPackages_latest.kernel")
kernel_unstable=$(get_unstable_version "linuxPackages_latest.kernel")
kernel_cache=$(check_cache "linuxPackages_latest.kernel")
if [[ "$kernel_local" == "N/A" || "$kernel_unstable" == "N/A" ]]; then
    kernel_status="?"
elif [[ "$kernel_local" == "$kernel_unstable" ]]; then
    kernel_status="="
else
    kernel_status="↑"
fi

# Stampa subito il kernel.
case "$kernel_status" in
    "=") kernel_status_colored="${GREEN}=${NC}" ;;
    "↑") kernel_status_colored="${RED}↑${NC}" ;;
    *)   kernel_status_colored="${YELLOW}?${NC}" ;;
esac
case "$kernel_cache" in
    "✓") kernel_cache_colored="${GREEN}✓${NC}" ;;
    "✗") kernel_cache_colored="${RED}✗${NC}" ;;
    *)   kernel_cache_colored="${YELLOW}?${NC}" ;;
esac
printf "\r%-60s\r" "" >&2
printf "│ %-9s │ %8s │ %-16s │ %-17s │ %b │ %b │\n" "Kernel" "-" "$kernel_local" "$kernel_unstable" "$kernel_status_colored" "$kernel_cache_colored"

# === ALTRI PACCHETTI ===
current=1  # Inizia da 1 perché il kernel è già stato controllato

for pkg in "${ORDERED_KEYS[@]}"; do
    current=$((current + 1))
    name="${PACKAGES[$pkg]}"

    # Mostra progresso su stderr (sovrascrive la stessa riga)
    printf "\r${YELLOW}[%d/%d] Controllando: %-20s${NC}" "$current" "$((total + 1))" "$name" >&2

    local_ver=$(get_local_version "$pkg")
    unstable_ver=$(get_unstable_version "$pkg")
    cache_status=$(check_cache "$pkg")
    closure_size=$(get_closure_size "$pkg")

    # Determina status versione
    if [[ "$local_ver" == "N/A" || "$unstable_ver" == "N/A" ]]; then
        status="?"
    elif [[ "$local_ver" == "$unstable_ver" ]]; then
        status="="
    else
        status="↑"
    fi

    # Formatta la dimensione
    size_formatted=$(format_size "$closure_size")

    case "$status" in
        "=") status_colored="${GREEN}=${NC}" ;;
        "↑") status_colored="${RED}↑${NC}" ;;
        *)   status_colored="${YELLOW}?${NC}" ;;
    esac

    case "$cache_status" in
        "✓") cache_colored="${GREEN}✓${NC}" ;;
        "✗") cache_colored="${RED}✗${NC}" ;;
        *)   cache_colored="${YELLOW}?${NC}" ;;
    esac

    # Pulisci la riga di progresso e stampa subito il risultato.
    printf "\r%-60s\r" "" >&2
    printf "│ %-9s │ %8s │ %-16s │ %-17s │ %b │ %b │\n" "$name" "$size_formatted" "$local_ver" "$unstable_ver" "$status_colored" "$cache_colored"
done

echo -e "└───────────┴──────────┴──────────────────┴───────────────────┴───┴───┘"
echo ""
echo -e "${BOLD}Legenda:${NC}"
echo -e "  ${BOLD}Peso${NC}:       Dimensione closure (pacchetto + dipendenze)"
echo -e "  ${BOLD}S${NC} (Status):  ${GREEN}=${NC} uguale  ${RED}↑${NC} aggiornamento  ${YELLOW}?${NC} sconosciuto"
echo -e "  ${BOLD}C${NC} (Cache):   ${GREEN}✓${NC} binario disponibile  ${RED}✗${NC} compilazione richiesta  ${YELLOW}?${NC} errore"
echo ""
echo -e "${RED}${BOLD}ATTENZIONE:${NC} Pacchetti con ${RED}✗${NC} nella colonna C richiedono compilazione (potenzialmente ore)"
echo ""
echo -e "${BOLD}Per aggiornare i pacchetti di sistema:${NC}"
if [[ "$HOST_INPUT" != "sconosciuto" ]]; then
    echo -e "    ${BLUE}nix flake update ${HOST_INPUT}${NC}"
    echo -e "    ${BLUE}o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake .#${HOST}${NC}"
else
    echo -e "    ${YELLOW}Host non riconosciuto: imposta HOST=<host> per ottenere i comandi contestuali${NC}"
fi
echo ""
echo -e "${BOLD}Note:${NC}"
echo -e "  - Non usare ${BLUE}nix flake update${NC} senza input: aggiorna tutti gli input insieme"
