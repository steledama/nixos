#!/usr/bin/env bash

# Simple wallpaper script for Hyprland using swaybg instead of hyprpaper
# This script finds a random wallpaper from the user's wallpaper directory
# and sets it using swaybg which works across different Wayland WMs

# Simple, consistent wallpaper directory
WALLPAPER_DIR="$HOME/wallpapers"

# Create the wallpaper directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Find a random wallpaper
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) 2>/dev/null | shuf -n 1)

if [ -z "$RANDOM_WALLPAPER" ]; then
  echo "No wallpapers found in $WALLPAPER_DIR"
  # Create a default dark wallpaper if none found
  TEMP_WALLPAPER="/tmp/default-wallpaper.png"
  convert -size 2560x1080 xc:#282c34 "$TEMP_WALLPAPER"
  RANDOM_WALLPAPER="$TEMP_WALLPAPER"
  echo "Created a default dark wallpaper"
fi

# Kill any existing swaybg instances
pkill swaybg 2>/dev/null

# Set wallpaper with swaybg
swaybg -i "$RANDOM_WALLPAPER" -m fill &

# Notify user
notify-send "Wallpaper" "Set new random wallpaper" --icon="$RANDOM_WALLPAPER"