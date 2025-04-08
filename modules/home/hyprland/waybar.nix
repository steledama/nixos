# modules/home/hyprland/waybar.nix
{
  pkgs,
  scripts,
  colors,
}: {
  enable = true;
  systemd.enable = false;
  settings = {
    mainBar = {
      layer = "top";
      position = "top";
      height = 30;
      modules-left = ["custom/menu" "hyprland/workspaces"];
      modules-center = ["custom/datetime"];
      modules-right = ["custom/notifications" "custom/keymap" "pulseaudio" "network" "battery" "custom/wlogout" "tray"];

      "hyprland/workspaces" = {
        format = "{icon}";
        on-click = "activate";
        sort-by-number = true;
        format-icons = {
          "1" = "1";
          "2" = "2";
          "3" = "3";
          "4" = "4";
          "5" = "5";
          "6" = "6";
          "7" = "7";
          "8" = "8";
          "9" = "9";
          "urgent" = "•";
          "active" = "•";
          "default" = "•";
        };
        all-outputs = true;
        active-only = false;
      };

      "custom/menu" = {
        format = "󰀻";
        tooltip = "Menu Applicazioni";
        on-click = "${pkgs.wofi}/bin/wofi --show drun";
      };

      "custom/datetime" = {
        exec = "LC_ALL=it_IT.UTF-8 date +'%A %d %B %H:%M'";
        interval = 30;
        format = "{}";
        tooltip = false;
      };

      "custom/notifications" = {
        format = "󰂚";
        tooltip = "Centro Notifiche";
        on-click = "swaync-client -t -sw";
        on-click-right = "swaync-client -C";
      };

      "tray" = {
        spacing = 10;
      };

      "network" = {
        format-wifi = "  {essid}";
        format-disconnected = "󰤭 ";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
      };

      "pulseaudio" = {
        format = "{icon} {volume}%";
        format-muted = "󰖁 ";
        format-icons = {
          default = ["󰕿" "󰖀" "󰕾"];
        };
        on-click = "pavucontrol";
      };

      "battery" = {
        format = "{icon} {capacity}%";
        format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        format-charging = "󰂄 {capacity}%";
        interval = 30;
        states = {
          warning = 30;
          critical = 15;
        };
      };

      "custom/keymap" = {
        format = "⌨";
        tooltip = false;
        on-click = "${scripts.shortcutScript}/bin/hyprland-shortcut";
      };

      "custom/wlogout" = {
        format = "⏻";
        tooltip = false;
        on-click = "${pkgs.wlogout}/bin/wlogout";
      };
    };
  };

  style = ''
    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 14px;
    }

    window#waybar {
      background-color: rgba(40, 44, 52, 0.9);
      color: ${colors.foreground};
    }

    #workspaces button {
      padding: 0 5px;
      color: ${colors.foreground};
      background-color: transparent;
      border-bottom: 3px solid transparent;
    }

    #workspaces button.active {
      background-color: rgba(97, 175, 239, 0.2);
      border-bottom: 3px solid ${colors.blue};
      font-weight: bold;
    }

    #workspaces button {
      font-size: 14px;
      padding: 0 8px;
      margin: 0 2px;
      transition: all 0.3s ease;
    }

    #custom-menu {
      color: ${colors.blue};
      font-size: 18px;
      padding: 0 10px;
      margin: 0 8px 0 4px;
      background-color: rgba(97, 175, 239, 0.1);
      border-radius: 5px;
    }

    #custom-menu:hover {
      background-color: rgba(97, 175, 239, 0.3);
      border-radius: 5px;
    }

    #clock, #battery, #pulseaudio, #network, #tray, #custom-keymap, #bluetooth, #custom-date, #custom-wlogout, #custom-notifications {
      padding: 0 10px;
      margin: 0 4px;
    }

    #custom-notifications {
      color: ${colors.green};
      font-size: 16px;
    }

    #custom-datetime {
      font-weight: bold;
      color: ${colors.yellow};
      min-width: 250px; /* Larghezza minima per evitare spostamenti */
    }

    #custom-keymap {
      color: ${colors.blue};
      font-size: 16px;
    }

    #custom-wlogout {
      color: ${colors.red};
      font-size: 16px;
    }

    #network {
      color: ${colors.green};
    }

    #pulseaudio {
      color: ${colors.purple};
    }

    #battery {
      color: ${colors.yellow};
    }

    #battery.warning {
      color: ${colors.yellow};
      animation: blink 1s infinite;
    }

    #battery.critical {
      color: ${colors.red};
      animation: blink 0.5s infinite;
    }

    @keyframes blink {
      to {
        opacity: 0.5;
      }
    }

    #custom-keymap:hover,
    #custom-notifications:hover,
    #pulseaudio:hover,
    #network:hover,
    #bluetooth:hover,
    #custom-wlogout:hover {
      background-color: rgba(97, 175, 239, 0.2);
      border-radius: 5px;
    }
  '';
}
