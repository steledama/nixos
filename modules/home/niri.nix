# modules/home/niri.nix
# Home-manager configuration for Niri window manager
{pkgs, ...} @ args: let
  # Keyboard default settings
  keyboardLayout =
    if args ? keyboardLayout
    then args.keyboardLayout
    else "us";
  keyboardVariant =
    if args ? keyboardVariant
    then args.keyboardVariant
    else "intl";
  keyboardOptions =
    if args ? keyboardOptions
    then args.keyboardOptions
    else "ralt:compose";

  # Colors for theming
  colors = import ./colors.nix;

  # Wofi (application launcher) configuration
  wofi = import ./wofi.nix {inherit colors pkgs;};

  # Waybar configuration with script references
  waybar = import ./waybar.nix {
    inherit pkgs colors;
    scripts = {
      shortcutScript = shortcutScript;
      wallpaperScript = wallpaperScript;
      monitorScript = monitorScript;
      screenshotScript = screenshotScript;
    };
  };

  # Lock screen script
  lockScreenScript = pkgs.writeShellScriptBin "lock-screen" ''
    #!/usr/bin/env bash
    ${pkgs.swaylock}/bin/swaylock -f "$@"
  '';

  # Wlogout configuration (logout menu)
  wlogoutLayout = let
    config = import ./wlogout.nix {inherit lockScreenScript;};
  in
    config.layout;

  # Shortcuts menu content and script
  shortcutsContent = builtins.readFile ./shortcuts-niri.md;
  shortcutShContent =
    builtins.replaceStrings
    ["__SHORTCUTS_CONTENT__"]
    [shortcutsContent]
    (builtins.readFile ./shortcuts.sh);

  # Monitor configuration script - adapting the Hyprland script for Niri
  monitorScript = pkgs.writeShellScriptBin "monitor" ''
    #!/usr/bin/env bash

    # This script is a placeholder for Niri monitor configuration
    # It can be expanded with Niri-specific monitor configuration commands

    notify-send "Monitor Configuration" "This feature is not yet fully implemented for Niri"

    # Basic implementation could involve modifying Niri's config file
    # or using niri-msg command when available
  '';

  # Wallpaper script for Niri (using the same script as Hyprland)
  wallpaperScript = pkgs.writeShellScriptBin "wallpaper" ''
    ${builtins.readFile ./wallpaper.sh}
  '';

  # Screenshot script with notifications (similar to Hyprland version)
  screenshotScript = pkgs.writeShellScriptBin "screenshot" ''
    #!/usr/bin/env bash

    # Script for screenshots with notification in Niri
    # Supports full screen, area selection, and active window screenshots

    SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
    mkdir -p "$SCREENSHOTS_DIR"

    TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
    FILENAME="$SCREENSHOTS_DIR/screenshot_$TIMESTAMP.png"

    case "$1" in
      "full")
        # Screenshot of the entire screen
        ${pkgs.grim}/bin/grim "$FILENAME"
        ;;
      "area")
        # Screenshot of a selected area
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$FILENAME"
        ;;
      "window")
        # For Niri, we don't have a direct "active window" selection yet
        # This is a fallback to area selection
        notify-send "Screenshot" "Window selection not fully implemented in Niri yet. Please select an area." --icon=dialog-information
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$FILENAME"
        ;;
      *)
        notify-send "Screenshot" "Usage: niri-screenshot [full|area|window]" --icon=dialog-information
        exit 1
        ;;
    esac

    # Copy to clipboard
    ${pkgs.wl-clipboard}/bin/wl-copy < "$FILENAME"

    # Notification with preview
    notify-send "Screenshot saved" "$FILENAME" --icon="$FILENAME"
  '';

  # Shortcut display script
  shortcutScript = pkgs.writeShellScriptBin "shortcut" ''
    ${shortcutShContent}
  '';
in {
  # Import related modules
  imports = [
    ./swaync.nix
  ];

  # Packages required for Niri (similar to Hyprland, but with Niri-specific tools)
  home.packages = with pkgs; [
    # Custom scripts
    shortcutScript
    wallpaperScript
    monitorScript
    screenshotScript
    lockScreenScript

    # Additional packages specific for Niri
    swaybg # Wallpaper setter for Wayland
    swayidle
  ];

  # Basic swaylock configuration
  programs.swaylock = {
    enable = true;
    settings = {
      color = "282c34";
      show-failed-attempts = true;
      ignore-empty-password = true;
      indicator-caps-lock = true;
      clock = true;
    };
  };

  # Auto-lock script
  home.file.".config/niri/auto-lock.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Terminate any running swayidle instances
      pkill swayidle

      # Start swayidle
      ${pkgs.swayidle}/bin/swayidle -w \
        timeout 570 'notify-send "Screen will be locked in 30 seconds" --urgency=low' \
        timeout 600 '${lockScreenScript}/bin/lock-screen' \
        before-sleep '${lockScreenScript}/bin/lock-screen'
    '';
  };

  # Niri configuration
  programs.niri = {
    enable = true;
    settings = {
      # General settings
      animation = {
        enabled = true;
      };

      # Input configuration
      input.keyboard.xkb = {
        layout = keyboardLayout;
        variant = keyboardVariant;
        options = keyboardOptions;
      };

      # Set up touchpad if available
      input.touchpad = {
        natural-scroll = true;
        tap = true;
        drag = true;
        drag-lock = true;
      };

      # Window layout preferences
      layout = {
        # Default to one window per column
        default = "tiling";
        # Enable window gaps
        gaps = 8;
        # Center focused column
        center-focused-column = true;
      };

      # Window decoration
      decoration = {
        # Rounded corners radius in pixels
        corner-radius = 8;
        # Blur
        blur = {
          enabled = true;
          passes = 2;
        };
      };

      # Window border settings
      border = {
        width = 2;
        active.color = "rgba(33ccffee)";
        inactive.color = "rgba(595959aa)";
      };

      # Autostart applications
      autostart = [
        "${pkgs.waybar}/bin/waybar"
        "${wallpaperScript}/bin/wallpaper"
        "${pkgs.blueman-applet}/bin/blueman-applet"
        "swaync" # Start SwayNC at boot
        "$HOME/.config/niri/auto-lock.sh"
      ];

      # Keyboard shortcuts - using similar bindings to Hyprland where possible
      keyboard-shortcuts = {
        # Basic application launchers
        "${toString "Super+Return"}" = "exec wezterm";
        "${toString "Super+r"}" = "exec wofi --show drun";
        "${toString "Super+b"}" = "exec google-chrome-stable";
        "${toString "Super+p"}" = "exec firefox";
        "${toString "Super+e"}" = "exec nautilus";
        "${toString "Super+n"}" = "exec swaync-client -t -sw";

        # Window controls
        "${toString "Super+q"}" = "close-window";
        "${toString "Super+Space"}" = "toggle-floating";

        # Focus navigation
        "${toString "Super+Left"}" = "focus-column-left";
        "${toString "Super+Right"}" = "focus-column-right";
        "${toString "Super+Up"}" = "focus-window-up";
        "${toString "Super+Down"}" = "focus-window-down";

        # Window movement
        "${toString "Super+Shift+Left"}" = "move-window-left";
        "${toString "Super+Shift+Right"}" = "move-window-right";
        "${toString "Super+Shift+Up"}" = "move-window-up";
        "${toString "Super+Shift+Down"}" = "move-window-down";

        # Window resizing
        "${toString "Super+Alt+Left"}" = "resize-window-width -5%";
        "${toString "Super+Alt+Right"}" = "resize-window-width +5%";
        "${toString "Super+Alt+Up"}" = "resize-window-height -5%";
        "${toString "Super+Alt+Down"}" = "resize-window-height +5%";

        # Workspaces
        "${toString "Super+1"}" = "workspace 1";
        "${toString "Super+2"}" = "workspace 2";
        "${toString "Super+3"}" = "workspace 3";
        "${toString "Super+4"}" = "workspace 4";
        "${toString "Super+5"}" = "workspace 5";
        "${toString "Super+6"}" = "workspace 6";
        "${toString "Super+7"}" = "workspace 7";
        "${toString "Super+8"}" = "workspace 8";
        "${toString "Super+9"}" = "workspace 9";

        # Move windows between workspaces
        "${toString "Super+Shift+1"}" = "move-window-to-workspace 1";
        "${toString "Super+Shift+2"}" = "move-window-to-workspace 2";
        "${toString "Super+Shift+3"}" = "move-window-to-workspace 3";
        "${toString "Super+Shift+4"}" = "move-window-to-workspace 4";
        "${toString "Super+Shift+5"}" = "move-window-to-workspace 5";
        "${toString "Super+Shift+6"}" = "move-window-to-workspace 6";
        "${toString "Super+Shift+7"}" = "move-window-to-workspace 7";
        "${toString "Super+Shift+8"}" = "move-window-to-workspace 8";
        "${toString "Super+Shift+9"}" = "move-window-to-workspace 9";

        # Switch workspaces
        "${toString "Super+Ctrl+Right"}" = "workspace +1";
        "${toString "Super+Ctrl+Left"}" = "workspace -1";

        # Niri-specific layout commands
        "${toString "Super+Tab"}" = "cycle-tiling-mode";
        "${toString "Super+c"}" = "center-column";
        "${toString "Super+f"}" = "toggle-fullscreen";
        "${toString "Super+d"}" = "toggle-fullscreen"; # Alternative binding to match common DE patterns

        # Utilities
        "${toString "Super+m"}" = "exec ${monitorScript}/bin/monitor";
        "${toString "Super+w"}" = "exec ${wallpaperScript}/bin/wallpaper";
        "${toString "Super+F1"}" = "exec ${shortcutScript}/bin/shortcut";
        "${toString "Super+Escape"}" = "exec ${pkgs.wlogout}/bin/wlogout";
        "${toString "Super+l"}" = "exec ${lockScreenScript}/bin/lock-screen";
        "${toString "Super+Shift+l"}" = "exec ${lockScreenScript}/bin/lock-screen && systemctl suspend";

        # Screenshots
        "${toString "Print"}" = "exec ${screenshotScript}/bin/screenshot full";
        "${toString "Shift+Print"}" = "exec ${screenshotScript}/bin/screenshot area";
        "${toString "Alt+Print"}" = "exec ${screenshotScript}/bin/screenshot window";
      };

      # Environment variables
      environment = {
        "MOZ_ENABLE_WAYLAND" = "1";
        "QT_QPA_PLATFORM" = "wayland;xcb";
        "GDK_BACKEND" = "wayland,x11";
        "SDL_VIDEODRIVER" = "wayland";
        "_JAVA_AWT_WM_NONREPARENTING" = "1";
        "XDG_CURRENT_DESKTOP" = "niri";
        "XDG_SESSION_TYPE" = "wayland";
        "XDG_SESSION_DESKTOP" = "niri";
        "NIXOS_OZONE_WL" = "1";
      };
    };
  };

  # Wofi configuration
  xdg.configFile."wofi/style.css".text = wofi.style;
  xdg.configFile."wofi/config".text = wofi.config;

  # Wlogout configuration
  xdg.configFile."wlogout/layout".text = wlogoutLayout;

  # Waybar configuration
  programs.waybar = waybar;
}
