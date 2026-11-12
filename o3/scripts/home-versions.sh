#!/usr/bin/env bash
# Script per confrontare versioni dei pacchetti pkgs-ai (stack agentico)
# vs disponibili su nixpkgs unstable e verificare disponibilità nella cache binaria
# Uso: ./home-versions.sh

set -euo pipefail

FLAKE_DIR="${FLAKE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$FLAKE_DIR"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${BOLD}Confronto versioni: pkgs-ai / input 'ai' (lockato) vs Nixpkgs Unstable${NC}"
echo -e "${BLUE}Flake directory: $FLAKE_DIR${NC}"
echo ""

# Ottieni la revisione di ai dal flake.lock
get_fresh_rev() {
    jq -r '.nodes["ai"].locked.rev' "$FLAKE_DIR/flake.lock" 2>/dev/null || echo ""
}

FRESH_REV=$(get_fresh_rev)
if [[ -z "$FRESH_REV" ]]; then
    echo -e "${RED}Errore: impossibile leggere la revisione di ai da flake.lock${NC}"
    exit 1
fi

FRESH_REV_SHORT="${FRESH_REV:0:7}"
echo -e "${BLUE}ai rev: ${FRESH_REV_SHORT}${NC}"
echo ""

# Funzione per ottenere versione dal ai lockato
get_fresh_version() {
    local pkg="$1"
    nix eval --raw "github:NixOS/nixpkgs/${FRESH_REV}#${pkg}.version" 2>/dev/null || echo "N/A"
}

# Funzione per ottenere versione da nixpkgs unstable (ultimo commit)
get_unstable_version() {
    local pkg="$1"
    nix eval --raw "github:NixOS/nixpkgs/nixos-unstable#${pkg}.version" 2>/dev/null || echo "N/A"
}

# Funzione per verificare se il pacchetto unstable è nella cache binaria
check_cache() {
    local pkg="$1"
    local pkg_path
    pkg_path=$(nix eval --raw "github:NixOS/nixpkgs/nixos-unstable#${pkg}.outPath" 2>/dev/null) || { echo "?"; return; }
    if nix path-info --store https://cache.nixos.org "$pkg_path" &>/dev/null; then
        echo "✓"
    else
        echo "✗"
    fi
}

# Header tabella
echo -e "${BOLD}┌─────────────────┬─────────────────────┬─────────────────────┬───┬───┐${NC}"
printf "${BOLD}│ %-15s │ %-19s │ %-19s │ S │ C │${NC}\n" "Pacchetto" "Versione Attuale" "Versione Unstable"
echo -e "${BOLD}├─────────────────┼─────────────────────┼─────────────────────┼───┼───┤${NC}"

# Lista pacchetti pkgs-ai (agenti e multiplexer)
declare -A PACKAGES=(
    ["claude-code"]="Claude Code"
    ["codex"]="OpenAI Codex"
    ["pi-coding-agent"]="Pi Coding Agent"
    ["herdr"]="Herdr"
)

# Ordine di visualizzazione
ORDERED_KEYS=(
    "claude-code"
    "codex"
    "pi-coding-agent"
    "herdr"
)

total=${#ORDERED_KEYS[@]}
current=0

for pkg in "${ORDERED_KEYS[@]}"; do
    current=$((current + 1))
    name="${PACKAGES[$pkg]}"

    # Mostra progresso su stderr
    printf "\r${YELLOW}[%d/%d] Controllando: %-15s${NC}" "$current" "$total" "$name" >&2

    fresh_ver=$(get_fresh_version "$pkg")
    unstable_ver=$(get_unstable_version "$pkg")
    cache_status=$(check_cache "$pkg")

    # Determina status versione
    if [[ "$fresh_ver" == "N/A" || "$unstable_ver" == "N/A" ]]; then
        status="?"
    elif [[ "$fresh_ver" == "$unstable_ver" ]]; then
        status="="
    else
        status="↑"
    fi

    # Colora lo status
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

    # Pulisci riga di progresso e stampa risultato
    printf "\r%-50s\r" "" >&2
    printf "│ %-15s │ %-19s │ %-19s │ %b │ %b │\n" "$name" "$fresh_ver" "$unstable_ver" "$status_colored" "$cache_colored"
done

echo -e "└─────────────────┴─────────────────────┴─────────────────────┴───┴───┘"
echo ""
echo -e "${BOLD}Legenda:${NC}"
echo -e "  ${BOLD}S${NC} (Status): ${GREEN}=${NC} aggiornato  ${RED}↑${NC} aggiornamento disponibile  ${YELLOW}?${NC} sconosciuto"
echo -e "  ${BOLD}C${NC} (Cache):  ${GREEN}✓${NC} binario disponibile  ${RED}✗${NC} compilazione richiesta  ${YELLOW}?${NC} errore"
echo ""
echo -e "${BOLD}Per aggiornare solo pkgs-ai:${NC}"
echo -e "  ${BLUE}nix flake update ai${NC}"
echo -e "  ${BLUE}o3/scripts/con-identita.sh home-manager switch --flake .#\$USER@\$(hostname)${NC}"
echo ""
echo -e "${BOLD}Note:${NC}"
echo -e "  - pkgs-ai usa un input separato per aggiornamenti indipendenti dello stack agentico"
echo -e "  - Aggiornare ai non richiede nixos-rebuild"
