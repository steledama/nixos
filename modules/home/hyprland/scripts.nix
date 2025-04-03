# modules/home/hyprland/scripts.nix
{pkgs}: let
  colors = import ./colors.nix;
  shortcutsText = builtins.readFile ./shortcuts.txt;
in {
  shortcutMenuScript = pkgs.writeShellScriptBin "shortcut-menu" ''
    #!/usr/bin/env bash

    # Script per mostrare le scorciatoie con formattazione compatta

    # Crea un file temporaneo per le scorciatoie
    TEMP_FILE=$(mktemp)

    # Popola il file con il contenuto delle scorciatoie
    cat > "$TEMP_FILE" << 'EOF'
    ${shortcutsText}
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
    #!/usr/bin/env bash

    # Monitor configuration script for Hyprland
    # Simplified to handle only a few specific configurations

    # Get current monitor information
    MONITORS=$(${pkgs.hyprland}/bin/hyprctl monitors -j)
    NUM_MONITORS=$(echo "$MONITORS" | ${pkgs.jq}/bin/jq '. | length')

    # Detect if we're at home (HDMI) or at work (DisplayPort)
    if ${pkgs.coreutils}/bin/cat /sys/class/drm/*/status | ${pkgs.gnugrep}/bin/grep -q "^DP-[0-9] connected"; then
      CONNECTION="DisplayPort"
      EXTERNAL_MONITOR="DP-1"
    elif ${pkgs.coreutils}/bin/cat /sys/class/drm/*/status | ${pkgs.gnugrep}/bin/grep -q "^HDMI-[0-9] connected"; then
      CONNECTION="HDMI"
      EXTERNAL_MONITOR="HDMI-A-1"
    else
      CONNECTION="Unknown"
      EXTERNAL_MONITOR=""
    fi

    # Function to apply monitor configs
    apply_monitor_config() {
      PROFILE="$1"
      case "$PROFILE" in
        "laptop-only")
          # Solo laptop - monitor interno
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,1920x1080,0x0,1"
          ${pkgs.hyprland}/bin/hyprctl keyword monitor ",disable"
          ;;
        "external-only")
          # Solo monitor esterno
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,disable"
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "$EXTERNAL_MONITOR,2560x1080,0x0,1"
          ;;
        "dual-stack")
          # Monitor esterno in alto, laptop in basso (centrato)
          # Configura il monitor esterno (2560x1080) in alto
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "$EXTERNAL_MONITOR,2560x1080,0x0,1"

          # Calcola l'offset per centrare il monitor del laptop (1920x1080) sotto il monitor esterno
          # (2560 - 1920) / 2 = 320 pixel di offset sul lato X
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,1920x1080,320x1080,1"
          ;;
        "dual-mirror")
          # Modalità mirror (stesso contenuto su entrambi)
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,1920x1080,0x0,1"
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "$EXTERNAL_MONITOR,preferred,0x0,1,mirror,eDP-1"
          ;;
        *)
          echo "Profilo non valido: $PROFILE"
          return 1
          ;;
      esac

      # Dopo aver cambiato configurazione, aggiorna lo sfondo
      ${randomWallpaperScript}/bin/hyprland-random-wallpaper

      # Notifica l'utente del cambio di profilo
      ${pkgs.libnotify}/bin/notify-send "Monitor" "Profilo $PROFILE applicato ($CONNECTION)"
    }

    # Show profile selector with current status
    select_profile() {
      OPTIONS="laptop-only\nexternal-only\ndual-stack\ndual-mirror"
      SELECTION=$(echo -e "$OPTIONS" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Monitor ($NUM_MONITORS rilevati, $CONNECTION)" --width 300 --height 200 --cache-file /dev/null)

      if [ -n "$SELECTION" ]; then
        apply_monitor_config "$SELECTION"
      fi
    }

    # Main execution
    select_profile
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
