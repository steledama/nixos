{pkgs}: {
  shortcutMenuScript = pkgs.writeShellScriptBin "shortcut-menu" ''
    #!/usr/bin/env bash

    # Script per mostrare le scorciatoie con formattazione compatta

    # Crea un file temporaneo per le scorciatoie
    TEMP_FILE=$(mktemp)

    # Popola il file con il contenuto delle scorciatoie
    cat > "$TEMP_FILE" << 'EOF'
    ${builtins.readFile ./shortcuts.txt}
    EOF

    # Mostra il menu utilizzando lo stile centralizzato e le dimensioni standard definite in wofi/config
    cat "$TEMP_FILE" | ${pkgs.wofi}/bin/wofi \
      --dmenu \
      --prompt "Shortcuts" \
      --cache-file /dev/null \
      --insensitive \
      --no-actions

    # Pulizia
    rm -f "$TEMP_FILE"
  '';

  randomWallpaperScript = pkgs.writeShellScriptBin "hyprland-random-wallpaper" ''
    #!/usr/bin/env bash

    # Simple wallpaper script for Hyprland
    # This script finds a random wallpaper from the user's wallpaper directory
    # and sets it as the wallpaper for different monitors

    # Simple, consistent wallpaper directory
    WALLPAPER_DIR="$HOME/wallpapers"
    TEMP_CONFIG="/tmp/hyprpaper.conf"

    # Create the wallpaper directory if it doesn't exist
    ${pkgs.coreutils}/bin/mkdir -p "$WALLPAPER_DIR"

    # Find a random wallpaper
    RANDOM_WALLPAPER=$(${pkgs.findutils}/bin/find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) 2>/dev/null | ${pkgs.coreutils}/bin/shuf -n 1)

    if [ -z "$RANDOM_WALLPAPER" ]; then
      echo "No wallpapers found in $WALLPAPER_DIR"
      # Create a default dark wallpaper if none found
      TEMP_WALLPAPER="/tmp/default-wallpaper.png"
      ${pkgs.imagemagick}/bin/convert -size 2560x1080 xc:#282c34 "$TEMP_WALLPAPER"
      RANDOM_WALLPAPER="$TEMP_WALLPAPER"
      echo "Created a default dark wallpaper"
    fi

    # Create a solid black background for the laptop monitor
    BLACK_WALLPAPER="/tmp/black-wallpaper.png"
    ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:#282c34 "$BLACK_WALLPAPER"

    # Terminate any existing hyprpaper instances
    if command -v ${pkgs.procps}/bin/pkill > /dev/null 2>&1; then
      ${pkgs.procps}/bin/pkill -f hyprpaper
    else
      # Alternative process termination if pkill is not available
      for pid in $(${pkgs.procps}/bin/ps -ef | ${pkgs.gnugrep}/bin/grep hyprpaper | ${pkgs.gnugrep}/bin/grep -v grep | ${pkgs.gawk}/bin/awk '{print $2}'); do
        kill -9 $pid 2>/dev/null
      done
    fi

    # Wait for the process to terminate
    sleep 1

    # Generate a hyprpaper configuration
    echo "preload = $RANDOM_WALLPAPER" > "$TEMP_CONFIG"
    echo "preload = $BLACK_WALLPAPER" >> "$TEMP_CONFIG"

    # Apply wallpapers based on monitor name
    for monitor in $(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[].name'); do
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
    ${pkgs.hyprpaper}/bin/hyprpaper --config "$TEMP_CONFIG" &

    echo "Set wallpapers: Main monitor: $RANDOM_WALLPAPER, Laptop: Dark theme"
  '';

  monitorConfigScript = pkgs.writeShellScriptBin "hyprland-monitor-config" ''
    # Il contenuto del precedente monitorConfigScript rimane invariato
    ${builtins.readFile ./scripts.nix}
  '';

  wlogoutScript = pkgs.writeShellScriptBin "hyprland-logout" ''
    #!/usr/bin/env bash

    # Basic wlogout script with clean configuration
    ${pkgs.wlogout}/bin/wlogout \
      --protocol layer-shell \
      --buttons-per-row 3 \
      --column-spacing 20 \
      --row-spacing 20 \
      --margin-top 300 \
      --margin-bottom 300 \
      --margin-left 300 \
      --margin-right 300
  '';
}
