# modules/home/hyprland.nix
{ config, pkgs, lib, ... }:

with lib;
let
  # Define the shortcut menu script
  hyprlandPackage = config.wayland.windowManager.hyprland.package or pkgs.hyprland;
  
  # Use a simple, consistent wallpaper directory
  wallpaperDir = "~/wallpapers";
  
  # Create a custom script package for the shortcut menu - ultra simplified direct approach
  shortcutMenuScript = pkgs.writeShellScriptBin "hyprland-shortcut-menu" ''
    #!/usr/bin/env bash
    
    # Extremely simplified approach to show Hyprland shortcuts
    # This simply shows the configuration itself, which is much more reliable
    
    # Function to extract shortcuts from Hyprland config
    extract_shortcuts() {
      # Store direct references to our configured bindings - these are exactly what we defined in the Nix file
      cat << EOF
    SUPER + Return => Launch Terminal
    SUPER + R => Open Application Launcher
    SUPER + B => Launch Firefox
    SUPER + E => Open File Manager
    SUPER + Q => Close Active Window
    SUPER + Space => Toggle Floating Window
    
    SUPER + Left => Focus Left
    SUPER + Right => Focus Right
    SUPER + Up => Focus Up
    SUPER + Down => Focus Down
    
    SUPER + 1 => Switch to Workspace 1
    SUPER + 2 => Switch to Workspace 2
    SUPER + 3 => Switch to Workspace 3
    SUPER + 4 => Switch to Workspace 4
    SUPER + 5 => Switch to Workspace 5
    
    SUPER + CTRL + Left => Previous Workspace
    SUPER + CTRL + Right => Next Workspace
    
    SUPER + SHIFT + 1 => Move Window to Workspace 1
    SUPER + SHIFT + 2 => Move Window to Workspace 2
    SUPER + SHIFT + 3 => Move Window to Workspace 3
    SUPER + SHIFT + 4 => Move Window to Workspace 4
    SUPER + SHIFT + 5 => Move Window to Workspace 5
    
    SUPER + W => Change Wallpaper
    SUPER + F1 => Show This Help Menu
    SUPER + SHIFT + E => Exit Hyprland
    EOF
    }
    
    # Show the shortcuts menu
    extract_shortcuts | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Hyprland Shortcuts" --width 800 --height 600 --cache-file /dev/null --insensitive
  '';

  # Create a custom script package for the random wallpaper
  randomWallpaperScript = pkgs.writeShellScriptBin "hyprland-random-wallpaper" ''
    #!/usr/bin/env bash

    # Random wallpaper script for Hyprland
    # This script finds a random wallpaper from the user's wallpaper directory
    # and sets it as the current wallpaper using hyprpaper

    # Simple, consistent wallpaper directory
    WALLPAPER_DIR="$HOME/wallpapers"
    TEMP_CONFIG="/tmp/hyprpaper.conf"

    # Create the wallpaper directory if it doesn't exist
    ${pkgs.coreutils}/bin/mkdir -p "$WALLPAPER_DIR"

    # Find a random wallpaper
    RANDOM_WALLPAPER=$(${pkgs.findutils}/bin/find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) 2>/dev/null | ${pkgs.coreutils}/bin/shuf -n 1)

    if [ -z "$RANDOM_WALLPAPER" ]; then
      echo "No wallpapers found in $WALLPAPER_DIR"
      # Create a default black wallpaper if none found
      TEMP_WALLPAPER="/tmp/default-wallpaper.png"
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:black "$TEMP_WALLPAPER"
      RANDOM_WALLPAPER="$TEMP_WALLPAPER"
      echo "Created a default black wallpaper"
    fi

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

    # Generate a hyprpaper configuration with the selected wallpaper
    echo "preload = $RANDOM_WALLPAPER" > "$TEMP_CONFIG"
    echo "wallpaper = ,$RANDOM_WALLPAPER" >> "$TEMP_CONFIG"

    # Start hyprpaper with the new configuration
    ${pkgs.hyprpaper}/bin/hyprpaper --config "$TEMP_CONFIG" &

    echo "Set random wallpaper: $RANDOM_WALLPAPER"
  '';

  # Create a default hyprpaper config
  defaultHyprpaperConfig = pkgs.writeText "hyprpaper.conf" ''
    preload = ~/wallpapers/default-wallpaper.jpg
    # Set a default fallback wallpaper
    wallpaper = ,~/wallpapers/default-wallpaper.jpg
  '';
in
{
  # Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # General minimal settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Input with Italian keyboard support
      input = {
        kb_layout = "it";
        follow_mouse = 1;
      };

      # Animations
      animations = {
        enabled = true;
      };

      # Window rules
      windowrulev2 = [
        "float,class:^(pavucontrol)$"
        # Rules for the shortcuts menu window
        "float,title:^(Hyprland Shortcuts)$"
        "size 800 600,title:^(Hyprland Shortcuts)$"
        "center,title:^(Hyprland Shortcuts)$"
      ];

      # Applications at startup
      exec-once = [
        "waybar"
        "${randomWallpaperScript}/bin/hyprland-random-wallpaper"
      ];

      # Shortcuts
      bind = [
        # Basic applications
        "SUPER, Return, exec, wezterm"
        "SUPER, R, exec, wofi --show drun"
        "SUPER, B, exec, firefox"
        "SUPER, E, exec, nautilus"

        # Window controls
        "SUPER, Q, killactive,"
        "SUPER, Space, togglefloating,"

        # Focus navigation
        "SUPER, Left, movefocus, l"
        "SUPER, Right, movefocus, r"
        "SUPER, Up, movefocus, u"
        "SUPER, Down, movefocus, d"

        # Workspace navigation
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        # Additional workspace navigation
        "SUPER CTRL, Right, workspace, e+1"
        "SUPER CTRL, Left, workspace, e-1"

        # Move windows to workspace
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"

        # Random wallpaper shortcut
        "SUPER, W, exec, ${randomWallpaperScript}/bin/hyprland-random-wallpaper"

        # Show keyboard shortcuts
        "SUPER, F1, exec, ${shortcutMenuScript}/bin/hyprland-shortcut-menu"

        # Logout
        "SUPER SHIFT, E, exec, hyprctl dispatch exit"
      ];
    };
  };

  # Add scripts to packages
  home.packages = [ 
    shortcutMenuScript 
    randomWallpaperScript 
    pkgs.hyprpaper
    pkgs.imagemagick # For fallback wallpaper creation
  ];

  # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = ["hyprland/workspaces"];
        modules-center = ["clock"];
        modules-right = ["custom/keymap" "tray"];

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
          };
        };

        "clock" = {
          format = "{:%H:%M}";
          tooltip-format = "{:%Y-%m-%d}";
        };

        "tray" = {
          spacing = 10;
        };
        
        # Custom module for keyboard shortcuts menu
        "custom/keymap" = {
          format = "⌨";
          tooltip = "Show Hyprland Shortcuts";
          on-click = "${shortcutMenuScript}/bin/hyprland-shortcut-menu";
        };
      };
    };

    # Style configuration for Waybar
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }

      window#waybar {
        background-color: rgba(0, 0, 0, 0.8);
        color: #ffffff;
      }

      #workspaces button {
        padding: 0 5px;
        color: #ffffff;
      }

      #workspaces button.active {
        background-color: rgba(0, 100, 200, 0.5);
      }

      #clock, #tray, #custom-keymap {
        padding: 0 10px;
      }
      
      /* Style for the keymap button */
      #custom-keymap {
        color: #61afef;
        font-size: 16px;
      }
      
      /* Hover effect for better user feedback */
      #custom-keymap:hover {
        background-color: rgba(97, 175, 239, 0.2);
        border-radius: 5px;
      }
    '';
  };

  # Create wallpapers directory during activation
  home.activation.createWallpaperDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/wallpapers
  '';

  # Wofi configuration (needed for the shortcut menu)
  programs.wofi = {
    enable = true;
    settings = {
      width = 500;
      height = 300;
      show = "drun";
      prompt = "Search...";
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }

      window {
        background-color: rgba(0, 0, 0, 0.8);
        color: #ffffff;
      }
    '';
  };
}
