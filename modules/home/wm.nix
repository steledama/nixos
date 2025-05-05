# modules/home/wm.nix
# Common configuration for all Wayland window managers
{
  pkgs,
  lib,
  ...
}: {
  options.wm = {
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

    # Monitors configuration
    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Monitor name/identifier (e.g., 'DP-2', 'DSI-1' run 'wlr-randr' for yours display names)";
          };
          mode = lib.mkOption {
            type = lib.types.submodule {
              options = {
                width = lib.mkOption {
                  type = lib.types.int;
                  description = "Width in pixels";
                };
                height = lib.mkOption {
                  type = lib.types.int;
                  description = "Height in pixels";
                };
              };
            };
            default = null;
            description = "Monitor resolution";
          };
          position = lib.mkOption {
            type = lib.types.submodule {
              options = {
                x = lib.mkOption {
                  type = lib.types.int;
                  default = 0;
                  description = "X position of the monitor";
                };
                y = lib.mkOption {
                  type = lib.types.int;
                  default = 0;
                  description = "Y position of the monitor";
                };
              };
            };
            default = {
              x = 0;
              y = 0;
            };
            description = "Monitor position coordinates";
          };
          scale = lib.mkOption {
            type = lib.types.float;
            default = 1.0;
            description = "Monitor scale factor";
          };
          transform = lib.mkOption {
            type = lib.types.enum [
              "normal"
              "90"
              "180"
              "270"
              "flipped"
              "flipped-90"
              "flipped-180"
              "flipped-270"
              ""
            ];
            default = "normal";
            description = "Monitor transform/rotation (e.g., '90', '270')";
          };
          wallpaper = lib.mkOption {
            type = lib.types.submodule {
              options = {
                path = lib.mkOption {
                  type = lib.types.str;
                  default = "~/Pictures/wallpaper.jpg";
                  description = "Path to wallpaper image for this monitor";
                };
                mode = lib.mkOption {
                  type = lib.types.enum ["stretch" "fill" "fit" "center" "tile"];
                  default = "fill";
                  description = "Wallpaper display mode";
                };
              };
            };
            default = {};
            description = "Wallpaper configuration for this monitor";
          };
        };
      });
      default = [
        {
          name = "default";
          wallpaper = {
            path = "~/Pictures/wallpaper.jpg";
            mode = "fill";
          };
        }
      ];
      description = "List of monitor configurations including wallpapers";
    };

    screenshots = {
      path = lib.mkOption {
        type = lib.types.str;
        default = "~/Pictures/Screenshot-%Y-%m-%d %H-%M-%S.png";
        description = "Path template for saving screenshots";
      };
    };
  };

  config = {
    # Common packages for Wayland WMs at user level
    home.packages = with pkgs; [
      swaybg # Wallpaper tool for Wayland compositors
      swaylock # Screen locker for Wayland
      wlogout # Wayland based logout menu
      swaynotificationcenter # Simple notification daemon with a GUI (swaync)
      libnotify # Library that sends desktop notifications to a notification daemon
      fuzzel # Wayland-native application launcher
      networkmanagerapplet # NetworkManager control applet
      pavucontrol # PulseAudio Volume Control
      (import ../../pkgs/screen-locker.nix {inherit pkgs;}) # Custom lock screen script
    ];

    # Basic wlogout configuration - extremely minimalist
    xdg.configFile."wlogout/layout".text = ''
      {
          "label" : "lock",
          "action" : "screen-locker",
          "text" : "Lock",
          "keybind" : "l"
      }
      {
          "label" : "hibernate",
          "action" : "systemctl hibernate",
          "text" : "Hibernate",
          "keybind" : "h"
      }
      {
          "label" : "logout",
          "action" : "loginctl terminate-user $USER",
          "text" : "Logout",
          "keybind" : "e"
      }
      {
          "label" : "shutdown",
          "action" : "systemctl poweroff",
          "text" : "Shutdown",
          "keybind" : "s"
      }
      {
          "label" : "suspend",
          "action" : "systemctl suspend",
          "text" : "Suspend",
          "keybind" : "u"
      }
      {
          "label" : "reboot",
          "action" : "systemctl reboot",
          "text" : "Reboot",
          "keybind" : "r"
      }
    '';
  };
}
