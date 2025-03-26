# modules/home/hyprland.nix

{ ... }:

{
  # Configurazione minima per Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Impostazioni generali minime
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Input con supporto italiano
      input = {
        kb_layout = "it";
        follow_mouse = 1;
      };

      # Animazioni minime
      animations = {
        enabled = true;
      };

      # Regole di finestra minime
      windowrulev2 = [
        "float,class:^(pavucontrol)$"
      ];

      # Solo le applicazioni essenziali all'avvio
      exec-once = [
        "waybar"
      ];

      # Scorciatoie essenziali
      bind = [
        # Applicazioni base
        "SUPER, Return, exec, wezterm"
        "SUPER, R, exec, wofi --show drun"
        "SUPER, B, exec, firefox"
        "SUPER, E, exec, nautilus"

        # Finestra
        "SUPER, Q, killactive,"
        "SUPER, Space, togglefloating,"

        # Navigazione
        "SUPER, Left, movefocus, l"
        "SUPER, Right, movefocus, r"
        "SUPER, Up, movefocus, u"
        "SUPER, Down, movefocus, d"

        # Workspace
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"

        # Move windows to workspace
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"

        # Logout
        "SUPER SHIFT, E, exec, hyprctl dispatch exit"
      ];
    };
  };

  # Configurazione Waybar minima
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" ];

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

    # Stile minimale
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

  # Configurazione Wofi minima
  programs.wofi = {
    enable = true;
    settings = {
      width = 500;
      height = 300;
      show = "drun";
      prompt = "Cerca...";
    };

    # Stile minimale
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
