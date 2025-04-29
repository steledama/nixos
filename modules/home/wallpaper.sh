#!/usr/bin/env bash

# Simple wallpaper script for Hyprland
# This script finds a random wallpaper from the user's wallpaper directory
# and sets it as the wallpaper for different monitors

# Simple, consistent wallpaper directory
WALLPAPER_DIR="$HOME/wallpapers"
TEMP_CONFIG="/tmp/hyprpaper.conf"

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

# Create a solid black background for the laptop monitor
BLACK_WALLPAPER="/tmp/black-wallpaper.png"
convert -size 1920x1080 xc:#282c34 "$BLACK_WALLPAPER"

# Terminate any existing hyprpaper instances
if command -v pkill > /dev/null 2>&1; then
  pkill -f hyprpaper
else
  # Alternative process termination if pkill is not available
  for pid in $(ps -ef | grep hyprpaper | grep -v grep | awk '{print $2}'); do
    kill -9 $pid 2>/dev/null
  done
fi

# Wait for the process to terminate
sleep 1

# Generate a hyprpaper configuration
echo "preload = $RANDOM_WALLPAPER" > "$TEMP_CONFIG"
echo "preload = $BLACK_WALLPAPER" >> "$TEMP_CONFIG"

# Apply wallpapers based on monitor name
for monitor in $(hyprctl monitors -j | jq -r '.[].name'); do
  if [ "$monitor" = "eDP-1" ]; then
    # Laptop display gets dark background
    echo "wallpaper = $monitor,$BLACK_WALLPAPER" >> "$TEMP_CONFIG"
  elif [ "$monitor" = "DP-1" ] || [ "$monitor" = "HDMI-A-1" ]; then
    # External display gets the random wallpaper
    echo "wallpaper = $monitor,$RANDOM_WALLPAPER" >> "$TEMP_CONFIG"
  else
    # Default for any other monitor
    echo "wallpaper = $monitor,$RANDOM_WALLPAPER" >> "$TEMP_CONFIG"
  fi
done

# Start hyprpaper with the new configuration
hyprpaper --config "$TEMP_CONFIG" &

echo "Set wallpapers: Main monitor: $RANDOM_WALLPAPER, Laptop: Dark theme"
