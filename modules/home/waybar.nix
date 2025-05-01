# modules/home/waybar.nix
# Shared Waybar configuration for both Niri and Hyprland
{ config, lib, pkgs, ... }:

let
  # Modern and elegant color palette
  colors = {
    background = "#1a1b26";
    foreground = "#c0caf5";
    black = "#15161e";
    red = "#f7768e";
    green = "#9ece6a";
    yellow = "#e0af68";
    blue = "#7aa2f7";
    purple = "#bb9af7";
    cyan = "#7dcfff";
    white = "#a9b1d6";
    transparent = "#00000000";
  };
in {
  programs.waybar = {
    enable = true;
    systemd.enable = false;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
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
        transition: 0.2s ease;
      }

      window#waybar {
        background-color: ${colors.background}cc;
        border-radius: 12px;
        border: 2px solid ${colors.blue}33;
        box-shadow: 0 2px 6px ${colors.black}80;
      }

      #custom-menu {
        font-size: 18px;
        color: ${colors.blue};
        padding: 0 12px;
        margin: 4px 8px 4px 4px;
        border-radius: 10px;
      }

      #custom-menu:hover {
        background-color: ${colors.blue}22;
      }

      #custom-datetime {
        color: ${colors.foreground};
        font-weight: bold;
        font-size: 14.5px;
        min-width: 250px;
        text-shadow: 0 1px 2px ${colors.black}40;
      }

      #custom-notifications {
        font-size: 16px;
        color: ${colors.yellow};
        margin-right: 6px;
        border-radius: 8px;
        padding: 0 10px;
      }

      #custom-notifications:hover {
        background-color: ${colors.yellow}22;
      }

      #custom-wlogout {
        font-size: 16px;
        color: ${colors.red};
        margin: 0 2px 0 6px;
        border-radius: 8px;
        padding: 0 10px;
      }

      #custom-wlogout:hover {
        background-color: ${colors.red}22;
      }

      #network {
        color: ${colors.cyan};
        border-radius: 8px;
        padding: 0 12px;
      }

      #network:hover {
        background-color: ${colors.cyan}22;
      }

      #network.disconnected {
        color: ${colors.red};
      }

      #pulseaudio {
        color: ${colors.green};
        border-radius: 8px;
        padding: 0 12px;
      }

      #pulseaudio:hover {
        background-color: ${colors.green}22;
      }

      #pulseaudio.muted {
        color: ${colors.red};
      }

      #battery {
        color: ${colors.purple};
        border-radius: 8px;
        padding: 0 12px;
      }

      #battery:hover {
        background-color: ${colors.purple}22;
      }

      #battery.warning {
        color: ${colors.yellow};
        animation: pulse 1.5s infinite;
      }

      #battery.critical {
        color: ${colors.red};
        animation: pulse 0.8s infinite;
      }

      @keyframes pulse {
        0% { opacity: 1; }
        50% { opacity: 0.6; }
        100% { opacity: 1; }
      }

      #tray {
        margin-left: 4px;
        padding: 0 10px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
      }

      /* Button hover effects */
      #clock, #battery, #pulseaudio, #network, #tray, #custom-keymap, #bluetooth, #custom-datetime, #custom-wlogout, #custom-notifications {
        margin: 4px;
        padding: 0 10px;
      }

      #custom-menu, #pulseaudio, #network, #battery, #custom-notifications, #custom-wlogout {
        border-radius: 8px;
        transition: all 0.2s ease;
      }

      /* Modules separator (subtle dot) */
      #battery, #network, #pulseaudio, #custom-notifications {
        margin-left: 5px;
        margin-right: 5px;
      }

      #battery:after,
      #network:after,
      #pulseaudio:after,
      #custom-notifications:after {
        content: "";
      }
    '';
  };
}
