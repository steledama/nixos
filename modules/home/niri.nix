# modules/home/niri.nix
{pkgs, ...} @ args: let
  # Keyboard default settings
  keyboardLayout =
    if args ? keyboardLayout
    then args.keyboardLayout
    else "us";
  keyboardVariant =
    if args ? keyboardVariant
    then args.keyboardVariant
    else "intl";
  keyboardOptions =
    if args ? keyboardOptions
    then args.keyboardOptions
    else "ralt:compose";

  # Colors for theming - reusing same colors from Hyprland
  colors = import ./colors.nix;

  # Wofi (application launcher) configuration - reused from Hyprland
  wofi = import ./wofi.nix {inherit colors pkgs;};

  # Waybar configuration with script references
  waybar = import ./waybar.nix {
    inherit pkgs colors;
    scripts = {
      shortcutScript = shortcutScript;
      wallpaperScript = wallpaperScript;
      monitorScript = monitorScript;
      screenshotScript = screenshotScript;
    };
  };

  # Lock screen script
  lockScreenScript = pkgs.writeShellScriptBin "lock-screen" ''
    #!/usr/bin/env bash
    ${pkgs.swaylock}/bin/swaylock -f -c 282c34
  '';

  # Wlogout configuration (logout menu) - reused from Hyprland
  wlogoutLayout = let
    config = import ./wlogout.nix {inherit lockScreenScript;};
  in
    config.layout;

  # Shortcuts menu content and script
  shortcutsContent = builtins.readFile ./shortcuts-niri.md;
  shortcutShContent =
    builtins.replaceStrings
    ["__SHORTCUTS_CONTENT__"]
    [shortcutsContent]
    (builtins.readFile ./shortcuts.sh);

  # Monitor configuration script for Niri
  monitorScript = pkgs.writeShellScriptBin "niri-monitor" ''
    #!/usr/bin/env bash
    
    MONITORS=$(swaymsg -t get_outputs | jq -r '.[].name')
    LAPTOP_MONITOR="eDP-1"  # Adapt to your laptop monitor name
    
    notify() {
      notify-send "Monitor Config" "$1" --icon=display
    }
    
    select_option() {
      OPTIONS="💻 Laptop only\n🖥️ External primary\n📺 Clone displays\n🖥️ External only"
      
      CHOICE=$(echo -e "$OPTIONS" | wofi --dmenu --prompt "Configure Monitors")
      
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
          notify "Operation canceled"
          exit 0
          ;;
      esac
    }
    
    laptop_only() {
      # This is simplified - in practice, you would use niri's
      # configuration system to manage outputs
      for monitor in $MONITORS; do
        if [ "$monitor" != "$LAPTOP_MONITOR" ]; then
          swaymsg output "$monitor" disable
        fi
      done
      swaymsg output "$LAPTOP_MONITOR" enable
      
      notify "Configured laptop monitor only"
      
      # Reload Niri configuration
      kill -SIGUSR1 $(pidof niri)
    }
    
    external_primary() {
      # Configure external monitors as primary
      has_external=false
      
      for monitor in $MONITORS; do
        if [ "$monitor" != "$LAPTOP_MONITOR" ]; then
          swaymsg output "$monitor" enable
          has_external=true
        fi
      done
      
      if [ "$has_external" = true ]; then
        swaymsg output "$LAPTOP_MONITOR" enable
        notify "External monitors configured as primary"
      else
        laptop_only
      fi
      
      # Reload Niri configuration
      kill -SIGUSR1 $(pidof niri)
    }
    
    clone_displays() {
      if [ "$(echo "$MONITORS" | wc -l)" -gt 1 ]; then
        for monitor in $MONITORS; do
          swaymsg output "$monitor" enable
        done
        notify "Monitors cloned"
      else
        laptop_only
      fi
      
      # Reload Niri configuration
      kill -SIGUSR1 $(pidof niri)
    }
    
    external_only() {
      has_external=false
      
      for monitor in $MONITORS; do
        if [ "$monitor" != "$LAPTOP_MONITOR" ]; then
          swaymsg output "$monitor" enable
          has_external=true
        fi
      done
      
      if [ "$has_external" = true ]; then
        swaymsg output "$LAPTOP_MONITOR" disable
        notify "Configured external monitors only"
      else
        laptop_only
      fi
      
      # Reload Niri configuration
      kill -SIGUSR1 $(pidof niri)
    }
    
    select_option
    
    # Apply wallpaper after changing monitor configuration
    ${wallpaperScript}/bin/niri-wallpaper
  '';

  # Wallpaper script for Niri
  wallpaperScript = pkgs.writeShellScriptBin "niri-wallpaper" ''
    #!/usr/bin/env bash
    
    # Simple wallpaper script for Niri
    # This script finds a random wallpaper from the user's wallpaper directory
    
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
      ${pkgs.imagemagick}/bin/convert -size 2560x1080 xc:#282c34 "$TEMP_WALLPAPER"
      RANDOM_WALLPAPER="$TEMP_WALLPAPER"
      echo "Created a default dark wallpaper"
    fi
    
    # Set the wallpaper using swaybg
    pkill -f swaybg
    ${pkgs.swaybg}/bin/swaybg -i "$RANDOM_WALLPAPER" -m fill &
    
    echo "Wallpaper set to: $RANDOM_WALLPAPER"
  '';

  # Screenshot script with notifications
  screenshotScript = pkgs.writeShellScriptBin "niri-screenshot" ''
    #!/usr/bin/env bash
    
    # Script for screenshots with notification in Niri
    # Supports full screen, selected area, and active window screenshots
    
    SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
    mkdir -p "$SCREENSHOTS_DIR"
    
    TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
    FILENAME="$SCREENSHOTS_DIR/screenshot_$TIMESTAMP.png"
    
    case "$1" in
      "full")
        # Screenshot of the entire screen
        ${pkgs.grim}/bin/grim "$FILENAME"
        ;;
      "area")
        # Screenshot of a selected area
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$FILENAME"
        ;;
      "window")
        # Screenshot of the active window
        # Note: This is simplified as niri doesn't have the same window info as Hyprland
        # We'll use slurp for window selection
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$FILENAME"
        ;;
      *)
        notify-send "Screenshot" "Usage: niri-screenshot [full|area|window]" --icon=dialog-information
        exit 1
        ;;
    esac
    
    # Copy to clipboard
    ${pkgs.wl-clipboard}/bin/wl-copy < "$FILENAME"
    
    # Notification with preview
    notify-send "Screenshot saved" "$FILENAME" --icon="$FILENAME"
  '';

  # Shortcut display script
  shortcutScript = pkgs.writeShellScriptBin "niri-shortcut" ''
    ${shortcutShContent}
  '';
in {
  # Import related modules
  imports = [
    ./swaync.nix
  ];

  # Packages required for Niri
  home.packages = with pkgs; [
    # Basic tools for the environment
    wlogout
    swaylock
    swayidle
    libnotify
    swaybg         # Wallpaper for Niri
    wf-recorder    # Screen recording

    # Custom scripts
    shortcutScript
    wallpaperScript
    monitorScript
    screenshotScript
    lockScreenScript
  ];

  # Basic swaylock configuration
  programs.swaylock = {
    enable = true;
    settings = {
      color = "282c34";
      show-failed-attempts = true;
      ignore-empty-password = true;
      indicator-caps-lock = true;
      clock = true;
    };
  };

  # Auto-lock script
  home.file.".config/niri/auto-lock.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Terminate any running swayidle instances
      pkill swayidle

      # Start swayidle
      ${pkgs.swayidle}/bin/swayidle -w \
        timeout 570 'notify-send "Screen will be locked in 30 seconds" --urgency=low' \
        timeout 600 '${lockScreenScript}/bin/lock-screen' \
        before-sleep '${lockScreenScript}/bin/lock-screen'
    '';
  };

  # Niri configuration
  wayland.windowManager.niri = {
    enable = true;
    settings = {
      # Input configuration
      input = {
        keyboard = {
          xkb = {
            layout = keyboardLayout;
            variant = keyboardVariant;
            options = keyboardOptions;
          };
        };
        
        touchpad = {
          natural-scroll = true;
          tap = true;
          disable-while-typing = true;
        };
      };
      
      # Preferences
      preferences = {
        # Set border width and colors
        border = {
          width = 2;
          active-color = "rgba(33ccffee)";
          inactive-color = "rgba(595959aa)";
        };
        
        # Set gaps between windows and to screen edges
        gaps = {
          inner = 5;
          outer = 10;
        };
        
        # Window corner radius
        corner-radius = 10;
      };
      
      # Animations
      animations = {
        window-open = {
          duration = 0.2; # In seconds
          curve = "ease-out-expo";
        };
        window-close = {
          duration = 0.2;
          curve = "ease-out-expo";
        };
      };
      
      # Environment variables
      environment = [
        "XCURSOR_SIZE=24"
        "XCURSOR_THEME=Adwaita"
        "GDK_BACKEND=wayland,x11"
        "QT_QPA_PLATFORM=wayland;xcb"
      ];
      
      # Window rules
      window-rules = [
        {
          matches = [{ app-id = "wofi"; }];
          float = true;
        }
        {
          matches = [{ app-id = "wlogout"; }];
          float = true;
        }
      ];
      
      # Keybindings
      key-bindings = [
        # Basic applications
        { modifiers = ["Super"]; key = "Return"; command = "Exec"; args = ["wezterm"]; }
        { modifiers = ["Super"]; key = "R"; command = "Exec"; args = ["wofi --show drun"]; }
        { modifiers = ["Super"]; key = "B"; command = "Exec"; args = ["google-chrome-stable"]; }
        { modifiers = ["Super"]; key = "P"; command = "Exec"; args = ["firefox"]; }
        { modifiers = ["Super"]; key = "E"; command = "Exec"; args = ["nautilus"]; }
        { modifiers = ["Super"]; key = "N"; command = "Exec"; args = ["swaync-client -t -sw"]; }
        
        # Window controls
        { modifiers = ["Super"]; key = "Q"; command = "CloseWindow"; }
        { modifiers = ["Super"]; key = "Space"; command = "ToggleFloat"; }
        
        # Window focus navigation
        { modifiers = ["Super"]; key = "Left"; command = "FocusWindowInDirection"; args = ["Left"]; }
        { modifiers = ["Super"]; key = "Right"; command = "FocusWindowInDirection"; args = ["Right"]; }
        { modifiers = ["Super"]; key = "Up"; command = "FocusWindowInDirection"; args = ["Up"]; }
        { modifiers = ["Super"]; key = "Down"; command = "FocusWindowInDirection"; args = ["Down"]; }
        
        # Window move
        { modifiers = ["Super", "Shift"]; key = "Left"; command = "MoveWindow"; args = ["Left"]; }
        { modifiers = ["Super", "Shift"]; key = "Right"; command = "MoveWindow"; args = ["Right"]; }
        { modifiers = ["Super", "Shift"]; key = "Up"; command = "MoveWindow"; args = ["Up"]; }
        { modifiers = ["Super", "Shift"]; key = "Down"; command = "MoveWindow"; args = ["Down"]; }
        
        # Window resize
        { modifiers = ["Super", "Alt"]; key = "Left"; command = "ResizeWindow"; args = ["Left", 20]; }
        { modifiers = ["Super", "Alt"]; key = "Right"; command = "ResizeWindow"; args = ["Right", 20]; }
        { modifiers = ["Super", "Alt"]; key = "Up"; command = "ResizeWindow"; args = ["Up", 20]; }
        { modifiers = ["Super", "Alt"]; key = "Down"; command = "ResizeWindow"; args = ["Down", 20]; }
        
        # Workspace navigation (numbers 1-9)
        { modifiers = ["Super"]; key = "1"; command = "FocusWorkspace"; args = [0]; }
        { modifiers = ["Super"]; key = "2"; command = "FocusWorkspace"; args = [1]; }
        { modifiers = ["Super"]; key = "3"; command = "FocusWorkspace"; args = [2]; }
        { modifiers = ["Super"]; key = "4"; command = "FocusWorkspace"; args = [3]; }
        { modifiers = ["Super"]; key = "5"; command = "FocusWorkspace"; args = [4]; }
        { modifiers = ["Super"]; key = "6"; command = "FocusWorkspace"; args = [5]; }
        { modifiers = ["Super"]; key = "7"; command = "FocusWorkspace"; args = [6]; }
        { modifiers = ["Super"]; key = "8"; command = "FocusWorkspace"; args = [7]; }
        { modifiers = ["Super"]; key = "9"; command = "FocusWorkspace"; args = [8]; }
        
        # Additional workspace navigation
        { modifiers = ["Super", "Ctrl"]; key = "Right"; command = "FocusWorkspaceNext"; }
        { modifiers = ["Super", "Ctrl"]; key = "Left"; command = "FocusWorkspacePrevious"; }
        
        # Moving windows between workspaces
        { modifiers = ["Super", "Shift"]; key = "1"; command = "MoveWindowToWorkspace"; args = [0]; }
        { modifiers = ["Super", "Shift"]; key = "2"; command = "MoveWindowToWorkspace"; args = [1]; }
        { modifiers = ["Super", "Shift"]; key = "3"; command = "MoveWindowToWorkspace"; args = [2]; }
        { modifiers = ["Super", "Shift"]; key = "4"; command = "MoveWindowToWorkspace"; args = [3]; }
        { modifiers = ["Super", "Shift"]; key = "5"; command = "MoveWindowToWorkspace"; args = [4]; }
        { modifiers = ["Super", "Shift"]; key = "6"; command = "MoveWindowToWorkspace"; args = [5]; }
        { modifiers = ["Super", "Shift"]; key = "7"; command = "MoveWindowToWorkspace"; args = [6]; }
        { modifiers = ["Super", "Shift"]; key = "8"; command = "MoveWindowToWorkspace"; args = [7]; }
        { modifiers = ["Super", "Shift"]; key = "9"; command = "MoveWindowToWorkspace"; args = [8]; }
        
        # Monitor configuration
        { modifiers = ["Super"]; key = "M"; command = "Exec"; args = ["${monitorScript}/bin/niri-monitor"]; }
        
        # Random wallpaper
        { modifiers = ["Super"]; key = "W"; command = "Exec"; args = ["${wallpaperScript}/bin/niri-wallpaper"]; }
        
        # Shortcuts menu
        { modifiers = ["Super"]; key = "F1"; command = "Exec"; args = ["${shortcutScript}/bin/niri-shortcut"]; }
        
        # Logout menu
        { modifiers = ["Super"]; key = "Escape"; command = "Exec"; args = ["${pkgs.wlogout}/bin/wlogout"]; }
        
        # Lock screen directly
        { modifiers = ["Super"]; key = "L"; command = "Exec"; args = ["${lockScreenScript}/bin/lock-screen"]; }
        { modifiers = ["Super", "Shift"]; key = "L"; command = "Exec"; args = ["${lockScreenScript}/bin/lock-screen && systemctl suspend"]; }
        
        # Screenshot shortcuts
        { modifiers = []; key = "Print"; command = "Exec"; args = ["${screenshotScript}/bin/niri-screenshot full"]; }
        { modifiers = ["Shift"]; key = "Print"; command = "Exec"; args = ["${screenshotScript}/bin/niri-screenshot area"]; }
        { modifiers = ["Alt"]; key = "Print"; command = "Exec"; args = ["${screenshotScript}/bin/niri-screenshot window"]; }
      ];
    };
  };

  # Autostart programs
  home.file.".config/niri/autostart.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      
      # Wallpaper
      ${wallpaperScript}/bin/niri-wallpaper &
      
      # Status bar
      ${pkgs.waybar}/bin/waybar &
      
      # Notification daemon
      swaync &
      
      # Auto-lock script
      $HOME/.config/niri/auto-lock.sh &
      
      # Bluetooth applet
      blueman-applet &
    '';
  };

  # Wofi configuration
  xdg.configFile."wofi/style.css".text = wofi.style;
  xdg.configFile."wofi/config".text = wofi.config;

  # Wlogout configuration
  xdg.configFile."wlogout/layout".text = wlogoutLayout;

  # Waybar configuration
  programs.waybar = waybar;
}
