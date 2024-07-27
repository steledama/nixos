#!/bin/bash

# Funzione per ottenere l'output HDMI connesso
get_hdmi_output() {
    xrandr | grep "HDMI.* connected" | cut -d " " -f1
}

# Funzione per ottenere l'output DP connesso
get_dp_output() {
    xrandr | grep "DP.* connected" | cut -d " " -f1
}

# Funzione per impostare la risoluzione HDMI
set_hdmi_resolution() {
    local hdmi_output=$(get_hdmi_output)
    if [ -n "$hdmi_output" ]; then
        xrandr --output "$hdmi_output" --mode 2560x1080
        echo "Risoluzione HDMI impostata a 2560x1080"
    else
        echo "Nessun output HDMI rilevato"
    fi
}

# Funzione per impostare la risoluzione DP (assumiamo che funzioni correttamente)
set_dp_resolution() {
    local dp_output=$(get_dp_output)
    if [ -n "$dp_output" ]; then
        echo "Output DP rilevato, assumiamo che la risoluzione sia corretta"
    else
        echo "Nessun output DP rilevato"
    fi
}

# Funzione principale
main() {
    if [ -n "$(get_hdmi_output)" ]; then
        set_hdmi_resolution
    elif [ -n "$(get_dp_output)" ]; then
        set_dp_resolution
    else
        echo "Nessun output esterno rilevato"
    fi
}

# Esegui la funzione principale
main
