# modules/home/hyprland.nix
{ pkgs, ... }:
let
  colors = import ./hyprland/colors.nix;
  wofi = import ./hyprland/wofi.nix { inherit colors pkgs; };
  waybar = import ./hyprland/waybar.nix {
    inherit pkgs colors;
    scripts = {
      shortcutMenuScript = shortcutMenuScript;
      randomWallpaperScript = randomWallpaperScript;
      monitorConfigScript = monitorConfigScript;
    };
  };

  monitorConfigScript = pkgs.writeShellScriptBin "hyprland-monitor-config" ''
    ${builtins.readFile ./hyprland/monitor-config.sh}
  '';

  randomWallpaperScript = pkgs.writeShellScriptBin "hyprland-random-wallpaper" ''
    ${builtins.readFile ./hyprland/wallpaper.sh}
  '';

  shortcutMenuScript = pkgs.writeShellScriptBin "shortcut-menu" ''
    #!/usr/bin/env bash

    # Script per mostrare le scorciatoie con formattazione compatta

    # Crea un file temporaneo per le scorciatoie
    TEMP_FILE=$(mktemp)

    # Popola il file con il contenuto delle scorciatoie
    cat > "$TEMP_FILE" << 'EOF'
    ${builtins.readFile ./hyprland/shortcuts.md}
    EOF

    # Mostra il menu utilizzando lo stile centralizzato e le dimensioni standard definite in wofi/config
    cat "$TEMP_FILE" | ${pkgs.wofi}/bin/wofi \
      --dmenu \
      --prompt "Shortcuts" \
      --cache-file /dev/null \
      --insensitive \
      --no-actions

    # Pulizia
    rm -f "$TEMP_FILE"
  '';
in
{
  # Packages required for Hyprland
  home.packages = with pkgs; [
    # Wlogout per logout menu
    wlogout

    # Script personalizzati
    shortcutMenuScript
    randomWallpaperScript
    monitorConfigScript
  ];

  # Hyprland Configuration
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    systemd.variables = [ "--systemd-activation" ];
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
        kb_layout = "it";
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
        "${randomWallpaperScript}/bin/hyprland-random-wallpaper"
        "${pkgs.waybar}/bin/waybar"
        "blueman-applet"
      ];

      # Keyboard shortcuts
      bind = [
        # Basic applications
        "SUPER, Return, exec, wezterm"
        "SUPER, R, exec, wofi --show drun"
        "SUPER, B, exec, google-chrome-stable"
        "SUPER, P, exec, firefox"
        "SUPER, E, exec, pcmanfm"

        # Window controls
        "SUPER, Q, killactive,"
        "SUPER, Space, togglefloating,"

        # Window focus navigation
        "SUPER, Left, movefocus, l"
        "SUPER, Right, movefocus, r"
        "SUPER, Up, movefocus, u"
        "SUPER, Down, movefocus, d"

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
        "SUPER, M, exec, ${monitorConfigScript}/bin/hyprland-monitor-config"

        # Random wallpaper
        "SUPER, W, exec, ${randomWallpaperScript}/bin/hyprland-random-wallpaper"

        # Shortcuts menu
        "SUPER, F1, exec, ${shortcutMenuScript}/bin/shortcut-menu"

        # Logout menu
        "SUPER, Escape, exec, ${pkgs.wlogout}/bin/wlogout"
      ];
    };
  };

  # Wofi configuration
  xdg.configFile."wofi/style.css".text = wofi.style;
  xdg.configFile."wofi/config".text = wofi.config;

  # Waybar configuration
  programs.waybar = waybar;
}
