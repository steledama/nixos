# modules/home/wm.nix
# Common configuration for all Wayland window managers
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.wayland-wm;
in {
  options.wayland-wm = {
    enable = lib.mkEnableOption "Enable common Wayland WM configuration";

    # Keyboard layout
    keyboard = {
      layout = lib.mkOption {
        type = lib.types.str;
        default = "us";
        description = "Keyboard layout";
      };

      variant = lib.mkOption {
        type = lib.types.str;
        default = "intl";
        description = "Keyboard variant";
      };

      options = lib.mkOption {
        type = lib.types.str;
        default = "ralt:compose";
        description = "Keyboard options";
      };
    };

    # Wallpaper
    wallpaper = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable wallpaper configuration";
      };

      # This is a map of output name -> color
      outputColors = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {"DP-3" = "#003366";};
        description = "Map of output names to background colors";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Common packages for Wayland WMs
    home.packages = with pkgs; [
      fuzzel # Wayland-native application launcher
      wl-clipboard # Command-line copy/paste utilities for Wayland
      pamixer # Pulseaudio command line mixer
      brightnessctl # read and control device brightness
      wlogout # Wayland based logout menu
      swaylock # Screen locker for Wayland
      swaynotificationcenter # Simple notification daemon with a GUI
      libnotify # Library that sends desktop notifications to a notification daemon
    ];

    # SwayLock
    programs.swaylock = {
      enable = true;
      settings = {
        clock = true;
        show-failed-attempts = true;
        ignore-empty-password = true;
        indicator-caps-lock = true;
        indicator-radius = 100;
        indicator-thickness = 7;
      };
    };

    # Waybar
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
          modules-right = ["custom/notifications" "network" "pulseaudio" "battery" "custom/wlogout" "tray"];

          # Menu button
          "custom/menu" = {
            format = "󰀻";
            tooltip = "Application Menu";
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

        #network {
          color: #7dcfff;
          border-radius: 8px;
          padding: 0 12px;
        }

        #network:hover {
          background-color: rgba(125, 207, 255, 0.13);
        }

        #network.disconnected {
          color: #f7768e;
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
      '';
    };
  };
}
