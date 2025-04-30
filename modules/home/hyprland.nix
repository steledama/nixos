# modules/home/hyprland.nix
# Home-manager configuration for Hyprland
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

  # Waybar configuration with script references
  waybar = import ./waybar.nix {
    inherit pkgs colors;
  };
in {
  # Import related modules
  imports = [
    ./swaync.nix
  ];

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

      # Miscellaneous configurations
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        enable_swallow = true;
      };

      # Startup applications
      exec-once = [
        "waybar"
        "swaync"
      ];

      # Keyboard shortcuts
      bind = [
        # Basic applications
        "SUPER, T, exec, alacritty"
        "SUPER, D, exec, fuzzel"
        "SUPER, B, exec, firefox"
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

        # Logout menu
        "SUPER, Escape, exec, wlogout"
      ];
    };
  };

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

  # Waybar configuration
  programs.waybar = waybar;
}
