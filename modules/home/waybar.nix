# modules/home/waybar.nix
# Waybar configuration for all Wayland window managers
{
  config,
  pkgs,
  lib,
  ...
}: {
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

        modules-left = ["custom/menu"];
        modules-center = ["custom/datetime"];
        modules-right = ["custom/notifications" "pulseaudio" "battery" "tray" "custom/wlogout"];

        # Menu button
        "custom/menu" = {
          format = "󰀻";
          tooltip = false;
          on-click = "fuzzel";
        };

        # Date and time
        "custom/datetime" = {
          exec = "date +'%A %-d %B %H:%M'";
          interval = 30;
          format = "{}";
          tooltip = false;
        };

        # Notification center
        "custom/notifications" = {
          format = "󰂚";
          tooltip = false;
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -C";
        };

        # Audio control
        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 Muted";
          format-icons = {
            default = ["󰕿" "󰖀" "󰕾"];
          };
          on-click = "pavucontrol";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
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
          tooltip-format = "{capacity}% - {time} remaining";
        };

        # System tray
        "tray" = {
          spacing = 10;
        };

        # Logout button
        "custom/wlogout" = {
          format = "⏻";
          tooltip = false;
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
        background-color: rgba(26, 27, 38, 0.8);
        border-radius: 12px;
        border: 2px solid rgba(122, 162, 247, 0.2);
        box-shadow: 0 2px 6px rgba(21, 22, 30, 0.5);
      }

      #custom-menu {
        font-size: 18px;
        color: #7aa2f7;
        padding: 0 12px;
        margin: 4px 8px 4px 4px;
        border-radius: 10px;
      }

      #custom-menu:hover {
        background-color: rgba(122, 162, 247, 0.13);
      }

      #custom-datetime {
        color: #c0caf5;
        font-weight: bold;
        font-size: 14.5px;
        min-width: 250px;
        text-shadow: 0 1px 2px rgba(21, 22, 30, 0.25);
      }

      #custom-notifications {
        font-size: 16px;
        color: #e0af68;
        margin-right: 6px;
        border-radius: 8px;
        padding: 0 10px;
      }

      #custom-notifications:hover {
        background-color: rgba(224, 175, 104, 0.13);
      }

      #pulseaudio {
        color: #9ece6a;
        border-radius: 8px;
        padding: 0 12px;
      }

      #pulseaudio:hover {
        background-color: rgba(158, 206, 106, 0.13);
      }

      #pulseaudio.muted {
        color: #f7768e;
      }

      #battery {
        color: #bb9af7;
        border-radius: 8px;
        padding: 0 12px;
      }

      #battery:hover {
        background-color: rgba(187, 154, 247, 0.13);
      }

      #battery.warning {
        color: #e0af68;
        animation: pulse 1.5s infinite;
      }

      #battery.critical {
        color: #f7768e;
        animation: pulse 0.8s infinite;
      }

      #tray {
        color: #7dcfff;
        border-radius: 8px;
        padding: 0 12px;
        margin-left: 4px;
      }

      #tray:hover {
        background-color: rgba(125, 207, 255, 0.13);
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
      }

      #custom-wlogout {
        font-size: 16px;
        color: #f7768e;
        margin: 0 2px 0 6px;
        border-radius: 8px;
        padding: 0 10px;
      }

      #custom-wlogout:hover {
        background-color: rgba(247, 118, 142, 0.13);
      }

      @keyframes pulse {
        0% { opacity: 1; }
        50% { opacity: 0.6; }
        100% { opacity: 1; }
      }

      /* Button hover effects */
      #custom-menu, #custom-notifications, #pulseaudio, #battery, #tray, #custom-wlogout {
        margin: 4px;
        padding: 0 10px;
        border-radius: 8px;
        transition: all 0.2s ease;
      }
    '';
  };
}
