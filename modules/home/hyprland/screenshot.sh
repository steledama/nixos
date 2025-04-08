#!/usr/bin/env bash

# Script per screenshot con notifica in Hyprland
# Supporta screenshot intero, di area selezionata e della finestra attiva

SCREENSHOTS_DIR="$HOME/Immagini/Schermate"
mkdir -p "$SCREENSHOTS_DIR"

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
FILENAME="$SCREENSHOTS_DIR/screenshot_$TIMESTAMP.png"

case "$1" in
  "full")
    # Screenshot dell'intero schermo
    grim "$FILENAME"
    ;;
  "area")
    # Screenshot di un'area selezionata
    grim -g "$(slurp)" "$FILENAME"
    ;;
  "window")
    # Screenshot della finestra attiva
    ACTIVE_WINDOW=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    if [ "$ACTIVE_WINDOW" != "," ]; then
      grim -g "$ACTIVE_WINDOW" "$FILENAME"
    else
      notify-send "Screenshot" "Nessuna finestra attiva" --icon=dialog-error
      exit 1
    fi
    ;;
  *)
    notify-send "Screenshot" "Uso: hyprland-screenshot [full|area|window]" --icon=dialog-information
    exit 1
    ;;
esac

# Copia nello clipboard
wl-copy < "$FILENAME"

# Notifica con anteprima
notify-send "Screenshot salvato" "$FILENAME" --icon="$FILENAME"