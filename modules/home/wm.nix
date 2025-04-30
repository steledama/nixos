# modules/home/wayland-wm.nix
# Common home-manager configuration for Wayland window managers (Hyprland, Niri)
{
  config,
  pkgs,
  lib,
  ...
}: let
  # Get configuration with defaults
  cfg = config.wayland-wm;

  # Import colors module for consistent theming across WMs
  colors = import ./colors.nix;

  # Create lock script that can be used by different components
  lockScreenScript = pkgs.writeShellScriptBin "lock-screen" ''
    ${pkgs.swaylock}/bin/swaylock \
      --color "${colors.background}" \
      --inside-color "${colors.background}" \
      --ring-color "${colors.blue}" \
      --inside-wrong-color "${colors.red}" \
      --ring-wrong-color "${colors.red}" \
      --inside-ver-color "${colors.yellow}" \
      --ring-ver-color "${colors.yellow}" \
      --indicator
  '';

  # Import wlogout configuration with lock script
  wlogoutConfig = import ./wlogout.nix {inherit lockScreenScript;};

  # Waybar configuration with colors
  waybarConfig = import ./waybar.nix {
    inherit pkgs colors;
  };
in {
  options.wayland-wm = {
    enable = lib.mkEnableOption "Enable common Wayland WM configuration";

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
  };

  config = lib.mkIf cfg.enable {
    # Import common notification manager
    imports = [
      ./swaync.nix
    ];

    # Common packages for Wayland WMs
    home.packages = with pkgs; [
      # App launchers
      fuzzel

      # System utilities
      wl-clipboard
      pamixer
      brightnessctl
      grim
      slurp

      # Logout menu
      wlogout

      # Lock screen utils
      swaylock

      # Add the lockscreen script
      lockScreenScript
    ];

    # SwayLock configuration
    programs.swaylock = {
      enable = true;
      settings = {
        color = lib.removePrefix "#" colors.background;
        clock = true;
        show-failed-attempts = true;
        ignore-empty-password = true;
        indicator-caps-lock = true;
        indicator-radius = 100;
        indicator-thickness = 7;
        line-color = lib.removePrefix "#" colors.foreground;
        ring-color = lib.removePrefix "#" colors.blue;
        inside-color = lib.removePrefix "#" colors.background;
        key-hl-color = lib.removePrefix "#" colors.green;
        separator-color = lib.removePrefix "#" colors.purple;
        text-color = lib.removePrefix "#" colors.foreground;
      };
    };

    # Waybar configuration
    programs.waybar = waybarConfig;
  };
}
