# modules/home/hyprland.nix
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
  colors = import ./hyprland/colors.nix;

  # Wofi (application launcher) configuration
  wofi = import ./hyprland/wofi.nix {inherit colors pkgs;};

  # Waybar configuration with script references
  waybar = import ./hyprland/waybar.nix {
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
    ${pkgs.hyprlock}/bin/hyprlock "$@"
  '';

  # Wlogout configuration (logout menu)
  wlogoutLayout = let
    config = import ./hyprland/wlogout.nix {inherit lockScreenScript;};
  in
    config.layout;

  # Shortcuts menu content and script
  shortcutsContent = builtins.readFile ./hyprland/shortcuts.md;
  shortcutShContent =
    builtins.replaceStrings
    ["__SHORTCUTS_CONTENT__"]
    [shortcutsContent]
    (builtins.readFile ./hyprland/shortcut.sh);

  # Monitor configuration script
  monitorScript = pkgs.writeShellScriptBin "hyprland-monitor" ''
    ${builtins.readFile ./hyprland/monitor.sh}
  '';

  # Wallpaper script
  wallpaperScript = pkgs.writeShellScriptBin "hyprland-wallpaper" ''
    ${builtins.readFile ./hyprland/wallpaper.sh}
  '';

  # Screenshot script with notifications
  screenshotScript = pkgs.writeShellScriptBin "hyprland-screenshot" ''
    ${builtins.readFile ./hyprland/screenshot.sh}
  '';

  # Shortcut display script
  shortcutScript = pkgs.writeShellScriptBin "hyprland-shortcut" ''
    ${shortcutShContent}
  '';
in {
  # Import related modules
  imports = [
    ./hyprland/swaync.nix
  ];

  # Packages required for Hyprland
  home.packages = with pkgs; [
    # Basic tools for the environment
    wlogout
    hyprlock
    swayidle
    libnotify

    # Custom scripts
    shortcutScript
    wallpaperScript
    monitorScript
    screenshotScript
    lockScreenScript
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
  home.file.".config/hypr/auto-lock.sh" = {
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

  # Hyprland Configuration
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    systemd.variables = ["--systemd-activation"];
    settings = {
      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Input configuration
      input = {
        kb_layout = keyboardLayout;
        kb_variant = keyboardVariant;
        kb_options = keyboardOptions;

        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
        };
      };

      # Animations
      animations = {
        enabled = true;
        animation = [
          "windows, 1, 3, default"
          "border, 1, 3, default"
          "fade, 1, 3, default"
          "workspaces, 1, 3, default"
        ];
      };

      # Decorations
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          new_optimizations = true;
        };
      };

      # Window layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Adwaita"
        "GDK_BACKEND,wayland,x11"
        "QT_QPA_PLATFORM,wayland;xcb"
      ];

      # Miscellaneous configurations
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        enable_swallow = true;
        swallow_regex = "^(wezterm)$";
      };

      # Startup applications
      exec-once = [
        "${wallpaperScript}/bin/hyprland-wallpaper"
        "${pkgs.waybar}/bin/waybar"
        "blueman-applet"
        "swaync" # Start SwayNC at boot
        "$HOME/.config/hypr/auto-lock.sh" # Start auto-lock at boot
      ];

      # Keyboard shortcuts
      bind = [
        # Basic applications
        "SUPER, Return, exec, wezterm"
        "SUPER, R, exec, wofi --show drun"
        "SUPER, B, exec, google-chrome-stable"
        "SUPER, P, exec, firefox"
        "SUPER, E, exec, nautilus"
        "SUPER, N, exec, swaync-client -t -sw"

        # Window controls
        "SUPER, Q, killactive,"
        "SUPER, Space, togglefloating,"

        # Window focus navigation
        "SUPER, Left, movefocus, l"
        "SUPER, Right, movefocus, r"
        "SUPER, Up, movefocus, u"
        "SUPER, Down, movefocus, d"

        # Window move
        "SUPER SHIFT, Left, movewindow, l"
        "SUPER SHIFT, Right, movewindow, r"
        "SUPER SHIFT, Up, movewindow, u"
        "SUPER SHIFT, Down, movewindow, d"

        # Window resize
        "SUPER ALT, Left, resizeactive, -20 0"
        "SUPER ALT, Right, resizeactive, 20 0"
        "SUPER ALT, Up, resizeactive, 0 -20"
        "SUPER ALT, Down, resizeactive, 0 20"

        # Window navigation
        "ALT, Tab, cyclenext,"
        "ALT_SHIFT, Tab, cyclenext, prev"

        # Workspace navigation (numbers 1-9)
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"

        # Additional workspace navigation
        "SUPER CTRL, Right, workspace, e+1"
        "SUPER CTRL, Left, workspace, e-1"

        # Moving windows between workspaces
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"
        "SUPER SHIFT, Right, movetoworkspace, e+1"
        "SUPER SHIFT, Left, movetoworkspace, e-1"

        # Monitor configuration
        "SUPER, M, exec, ${monitorScript}/bin/hyprland-monitor"

        # Random wallpaper
        "SUPER, W, exec, ${wallpaperScript}/bin/hyprland-wallpaper"

        # Shortcuts menu
        "SUPER, F1, exec, ${shortcutScript}/bin/hyprland-shortcut"

        # Logout menu
        "SUPER, Escape, exec, ${pkgs.wlogout}/bin/wlogout"

        # Lock screen directly
        "SUPER, L, exec, ${lockScreenScript}/bin/lock-screen"
        "SUPER SHIFT, L, exec, ${lockScreenScript}/bin/lock-screen && systemctl suspend"

        # Screenshot shortcuts
        ", Print, exec, ${screenshotScript}/bin/hyprland-screenshot full"
        "SHIFT, Print, exec, ${screenshotScript}/bin/hyprland-screenshot area"
        "ALT, Print, exec, ${screenshotScript}/bin/hyprland-screenshot window"
      ];
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
