#!/usr/bin/env bash

MONITORS=$(hyprctl monitors -j | jq -r '.[].name')
LAPTOP_MONITOR="eDP-1"  # Adatta al nome del tuo monitor laptop

notify() {
  notify-send "Monitor Config" "$1" --icon=display
}

select_option() {
  OPTIONS="💻 Laptop only\n🖥️ External primary\n📺 Clone displays\n🖥️ External only"
  
  CHOICE=$(echo -e "$OPTIONS" | wofi --dmenu --prompt "Configurazione Monitor")
  
  case "$CHOICE" in
    *"Laptop only"*)
      laptop_only
      ;;
    *"External primary"*)
      external_primary
      ;;
    *"Clone displays"*)
      clone_displays
      ;;
    *"External only"*)
      external_only
      ;;
    *)
      notify "Operation deleted"
      exit 0
      ;;
  esac
}

laptop_only() {
  hyprctl keyword monitor "$LAPTOP_MONITOR,preferred,0x0,1"
  
  for monitor in $MONITORS; do
    if [ "$monitor" != "$LAPTOP_MONITOR" ]; then
      hyprctl keyword monitor "$monitor,disable"
    fi
  done
  
  notify "Configurato solo il monitor del laptop"
}

external_primary() {
  y_position=0
  has_external=false
  
  for monitor in $MONITORS; do
    if [ "$monitor" != "$LAPTOP_MONITOR" ]; then
      hyprctl keyword monitor "$monitor,preferred,0x${y_position},1"
      height=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\") | .height")
      y_position=$((y_position + height))
      has_external=true
    fi
  done
  
  if [ "$has_external" = true ]; then
    hyprctl keyword monitor "$LAPTOP_MONITOR,preferred,0x${y_position},1"
    notify "Monitor esterni configurati come primari (sopra il laptop)"
  else
    laptop_only
  fi
}

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

external_only() {
  has_external=false
  
  hyprctl keyword monitor "$LAPTOP_MONITOR,disable"
  
  y_position=0
  for monitor in $MONITORS; do
    if [ "$monitor" != "$LAPTOP_MONITOR" ]; then
      hyprctl keyword monitor "$monitor,preferred,0x${y_position},1"
      height=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\") | .height")
      y_position=$((y_position + height))
      has_external=true
    fi
  done
  
  if [ "$has_external" = false ]; then
    laptop_only
  else
    notify "Configurati solo i monitor esterni"
  fi
}

select_option

hyprland-random-wallpaper
