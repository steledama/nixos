# modules/home/niri.nix
# Explicit function declaration for Niri window manager configuration
config: pkgs: let
  # Basic variables
  keyboardLayout = "us";
  keyboardVariant = "intl";

  # Colors for theming
  colors = import ./colors.nix;

  # Import Wofi configuration from the shared module
  wofi = import ./wofi.nix {inherit colors pkgs;};

  # Simple scripts
  shortcutScript = pkgs.writeShellScriptBin "shortcut" ''
    #!/usr/bin/env bash
    cat ${./shortcuts.md} | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Shortcuts"
  '';

  wallpaperScript = pkgs.writeShellScriptBin "wallpaper" ''
    #!/usr/bin/env bash
    WALLPAPER_DIR="$HOME/wallpapers"
    mkdir -p "$WALLPAPER_DIR"
    RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
    pkill swaybg 2>/dev/null
    swaybg -i "$RANDOM_WALLPAPER" -m fill &
  '';

  screenshotScript = pkgs.writeShellScriptBin "screenshot" ''
    #!/usr/bin/env bash
    SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
    mkdir -p "$SCREENSHOTS_DIR"
    TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
    FILENAME="$SCREENSHOTS_DIR/screenshot_$TIMESTAMP.png"

    case "$1" in
      "full") grim "$FILENAME" ;;
      "area") grim -g "$(slurp)" "$FILENAME" ;;
      *) grim "$FILENAME" ;;
    esac
    wl-copy < "$FILENAME"
  '';

  lockScreenScript = pkgs.writeShellScriptBin "lock-screen" ''
    #!/usr/bin/env bash
    ${pkgs.swaylock}/bin/swaylock -f
  '';
in {
  # Packages required for Niri
  home.packages = with pkgs; [
    # Custom scripts
    shortcutScript
    wallpaperScript
    screenshotScript
    lockScreenScript

    # Core dependencies
    swaybg
    swaylock
    swayidle
    wl-clipboard
    slurp
    grim
    jq
    wlogout
  ];

  # Basic swaylock configuration
  programs.swaylock = {
    enable = true;
    settings = {
      color = "282c34";
      clock = true;
    };
  };

  # Custom Niri configuration file
  xdg.configFile."niri/config.kdl" = {
    text = ''
      {
        "input": {
          "keyboard": {
            "xkb": {
              "layout": "${keyboardLayout}",
              "variant": "${keyboardVariant}"
            }
          },
          "touchpad": {
            "tap": true,
            "natural-scroll": true
          }
        },
        "layout": {
          "gaps": 8,
          "border": {
            "width": 2,
            "active": {
              "color": "${colors.blue}"
            },
            "inactive": {
              "color": "${colors.brightBlack}"
            }
          }
        },
        "binds": {
          "Mod+Return": {
            "action": {
              "spawn": ["wezterm"]
            }
          },
          "Mod+Q": {
            "action": {
              "close-window": {}
            }
          },
          "Mod+Space": {
            "action": {
              "toggle-window-floating": {}
            }
          },
          "Print": {
            "action": {
              "spawn": ["${screenshotScript}/bin/screenshot", "full"]
            }
          }
        }
      }
    '';
  };
}
