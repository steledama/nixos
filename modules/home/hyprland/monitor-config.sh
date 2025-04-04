#!/usr/bin/env bash

# Ottieni la lista dei monitor disponibili
MONITORS=$(hyprctl monitors -j | jq -r '.[].name')
LAPTOP_MONITOR="eDP-1"  # Adatta al nome del tuo monitor laptop

# Funzione per notificare l'utente
notify() {
  notify-send "Monitor Config" "$1" --icon=display
}

# Menu di selezione delle opzioni
select_option() {
  # Menu con icone per migliorare l'esperienza visiva
  OPTIONS="💻 Solo laptop\n🖥️ Esterni primari\n📺 Clona schermo\n🖥️ Esterno solo"
  
  CHOICE=$(echo -e "$OPTIONS" | wofi --dmenu --prompt "Configurazione Monitor")
  
  case "$CHOICE" in
    *"Solo laptop"*)
      laptop_only
      ;;
    *"Esterni primari"*)
      external_primary
      ;;
    *"Clona schermo"*)
      clone_displays
      ;;
    *"Esterno solo"*)
      external_only
      ;;
    *)
      notify "Operazione annullata"
      exit 0
      ;;
  esac
}

# Solo laptop
laptop_only() {
  hyprctl keyword monitor "$LAPTOP_MONITOR,preferred,0x0,1"
  
  # Disabilita tutti gli altri monitor
  for monitor in $MONITORS; do
    if [ "$monitor" != "$LAPTOP_MONITOR" ]; then
      hyprctl keyword monitor "$monitor,disable"
    fi
  done
  
  notify "Configurato solo il monitor del laptop"
}

# Esterni primari (il laptop diventa secondario)
external_primary() {
  y_position=0
  has_external=false
  
  # Prima configura i monitor esterni (sopra)
  for monitor in $MONITORS; do
    if [ "$monitor" != "$LAPTOP_MONITOR" ]; then
      # Configura il monitor esterno in posizione 0,0 (in alto)
      hyprctl keyword monitor "$monitor,preferred,0x${y_position},1"
      # Ottieni l'altezza del monitor esterno per posizionare il laptop sotto
      height=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\") | .height")
      y_position=$((y_position + height))
      has_external=true
    fi
  done
  
  if [ "$has_external" = true ]; then
    # Posiziona il laptop sotto lo schermo esterno
    hyprctl keyword monitor "$LAPTOP_MONITOR,preferred,0x${y_position},1"
    notify "Monitor esterni configurati come primari (sopra il laptop)"
  else
    laptop_only
  fi
}

# Clona tutti gli schermi
clone_displays() {
  if [ "$(echo "$MONITORS" | wc -l)" -gt 1 ]; then
    for monitor in $MONITORS; do
      hyprctl keyword monitor "$monitor,preferred,0x0,1"
    done
    notify "Monitor clonati"
  else
    laptop_only
  fi
}

# Solo monitor esterni
external_only() {
  has_external=false
  
  # Prima disabilita il laptop
  hyprctl keyword monitor "$LAPTOP_MONITOR,disable"
  
  y_position=0
  for monitor in $MONITORS; do
    if [ "$monitor" != "$LAPTOP_MONITOR" ]; then
      # Configura il monitor esterno - se ne hai più di uno, li impila verticalmente
      hyprctl keyword monitor "$monitor,preferred,0x${y_position},1"
      # Aggiorna la posizione Y per il prossimo monitor (se ce ne sono più di uno)
      height=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\") | .height")
      y_position=$((y_position + height))
      has_external=true
    fi
  done
  
  if [ "$has_external" = false ]; then
    # Se non ci sono monitor esterni, riattiva il laptop
    laptop_only
  else
    notify "Configurati solo i monitor esterni"
  fi
}

# Avvia il menu di selezione delle opzioni
select_option

# Riapplica lo sfondo dopo la configurazione
hyprland-random-wallpaper