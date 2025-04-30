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
  shortcutsContent = builtins.readFile ./shortcuts.md;
  shortcutShContent =
    builtins.replaceStrings
    ["__SHORTCUTS_CONTENT__"]
    [shortcutsContent]
    (builtins.readFile ./shortcuts.sh);

  # Wallpaper script for Niri (using the same script as Hyprland)
  wallpaperScript = pkgs.writeShellScriptBin "wallpaper" ''
    ${builtins.readFile ./wallpaper.sh}
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
    settings = {
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
        drag-lock = true;
      };

      # Window layout preferences
      layout = {
        # Enable window gaps
        gaps = 8;
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
