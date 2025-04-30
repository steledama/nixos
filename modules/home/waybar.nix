# modules/home/waybar-config.nix
# Shared Waybar configuration for both Niri and Hyprland
{ 
  pkgs, 
  colors 
}:

{
  enable = true;
  systemd.enable = false;
  settings = {
    mainBar = {
      layer = "top";
      position = "top";
      height = 30;
      margin = "5 5 0 5";
      spacing = 4;
      
      modules-left = ["custom/menu" "network"];
      modules-center = ["custom/datetime"];
      modules-right = ["custom/notifications" "pulseaudio" "battery" "custom/wlogout" "tray"];

      # Menu button
      "custom/menu" = {
        format = "󰀻";
        tooltip = "Application Menu";
        on-click = "fuzzel";
      };

      # Date and time
      "custom/datetime" = {
        exec = "date +'%A, %B %d  %H:%M'";
        interval = 30;
        format = "{}";
        tooltip = false;
      };

      # Notification center
      "custom/notifications" = {
        format = "󰂚";
        tooltip = "Notifications";
        on-click = "swaync-client -t -sw";
        on-click-right = "swaync-client -C";
      };

      # System tray
      "tray" = {
        spacing = 10;
      };

      # Network status
      "network" = {
        format-wifi = "  {essid}";
        format-ethernet = "󰈀 Connected";
        format-disconnected = "󰤭 Disconnected";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        on-click = "nm-connection-editor";
      };

      # Audio control
      "pulseaudio" = {
        format = "{icon} {volume}%";
        format-muted = "󰖁 Muted";
        format-icons = {
          default = ["󰕿" "󰖀" "󰕾"];
        };
        on-click = "pavucontrol";
      };

      # Battery status
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

      # Logout button
      "custom/wlogout" = {
        format = "⏻";
        tooltip = "Session";
        on-click = "wlogout";
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
      border-radius: 10px;
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

    #clock, #battery, #pulseaudio, #network, #tray, #custom-keymap, #bluetooth, #custom-datetime, #custom-wlogout, #custom-notifications {
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
      min-width: 250px; /* Minimum width to prevent shifting */
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
