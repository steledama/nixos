# modules/home/hyprland.nix
{...}: {
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
      ];

      # Applications at startup
      exec-once = [
        "waybar"
        "bash ~/.config/hypr/scripts/random-wallpaper.sh"
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
        "SUPER, W, exec, bash ~/.config/hypr/scripts/random-wallpaper.sh"

        # Logout
        "SUPER SHIFT, E, exec, hyprctl dispatch exit"
      ];
    };
  };

  # Scripts and configuration files
  home.file = {
    # hyprpaper config
    ".config/hypr/hyprpaper.conf".text = ''
      preload = ~/Immagini/Wallpapers/blue_sea_4-wallpaper-2560x1080.jpg
      # Set a default fallback wallpaper
      wallpaper = ,~/Immagini/Wallpapers/blue_sea_4-wallpaper-2560x1080.jpg
    '';

    # Random wallpaper script
    ".config/hypr/scripts/random-wallpaper.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # Directory containing wallpapers
        WALLPAPER_DIR="$HOME/Immagini/Wallpapers"
        CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"

        # Create the directory if it doesn't exist
        mkdir -p "$WALLPAPER_DIR"

        # Find a random wallpaper
        RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n 1)

        if [ -z "$RANDOM_WALLPAPER" ]; then
          echo "No wallpapers found in $WALLPAPER_DIR"
          exit 1
        fi

        # Kill existing hyprpaper instance if running
        killall hyprpaper 2>/dev/null

        # Generate a new hyprpaper config with the random wallpaper
        echo "preload = $RANDOM_WALLPAPER" > "$CONFIG_FILE"
        echo "wallpaper = ,$RANDOM_WALLPAPER" >> "$CONFIG_FILE"

        # Start hyprpaper with the new config
        hyprpaper &

        echo "Set random wallpaper: $RANDOM_WALLPAPER"
      '';
    };
  };

  # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = ["hyprland/workspaces"];
        modules-center = ["clock"];
        modules-right = ["tray"];

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
      };
    };

    # Style
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

      #clock, #tray {
        padding: 0 10px;
      }
    '';
  };

  # Wofi configuration
  programs.wofi = {
    enable = true;
    settings = {
      width = 500;
      height = 300;
      show = "drun";
      prompt = "Search...";
    };

    # Wofi style
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
