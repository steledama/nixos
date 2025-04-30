# modules/home/wayland-wm.nix
# Common home-manager configuration for Wayland window managers (Hyprland, Niri)
{ 
  config,
  pkgs, 
  lib,
  ...
} @ args: let
  # Get optional arguments with defaults
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
  wlogoutConfig = import ./wlogout.nix { inherit lockScreenScript; };

  # Waybar configuration with colors
  waybarConfig = import ./waybar-config.nix {
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

    # Wlogout configuration
    xdg.configFile."wlogout/layout".text = wlogoutConfig.layout;
    xdg.configFile."wlogout/style.css".text = ''
      * {
        background-image: none;
        font-family: "JetBrainsMono Nerd Font";
      }

      window {
        background-color: ${colors.background};
      }

      button {
        color: ${colors.foreground};
        background-color: ${colors.black};
        border-style: solid;
        border-width: 2px;
        border-radius: 10px;
        border-color: ${colors.blue};
        margin: 15px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
      }

      button:focus, button:active, button:hover {
        background-color: ${colors.blue};
        color: ${colors.black};
        outline-style: none;
      }

      #lock {
        background-image: image(url("icons/lock.png"));
      }

      #logout {
        background-image: image(url("icons/logout.png"));
      }

      #suspend {
        background-image: image(url("icons/suspend.png"));
      }

      #hibernate {
        background-image: image(url("icons/hibernate.png"));
      }

      #shutdown {
        background-image: image(url("icons/shutdown.png"));
      }

      #reboot {
        background-image: image(url("icons/reboot.png"));
      }
    '';

    # Create icons directory structure
    home.file.".config/wlogout/icons/" = {
      source = ./wlogout-icons;
      recursive = true;
    };
  };
}
