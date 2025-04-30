# modules/home/hyprland.nix
# Home-manager configuration for Hyprland using common Wayland components
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Get keyboard settings from wayland-wm configuration
  cfg = config.wayland-wm;
  colors = import ./colors.nix;
in {
  # Import common Wayland WM configuration
  imports = [
    ./wm.nix
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
        "col.active_border" = "rgba(${colors.blue}ee)";
        "col.inactive_border" = "rgba(${colors.brightBlack}aa)";
        layout = "dwindle";
      };

      # Input configuration
      input = {
        kb_layout = cfg.keyboard.layout;
        kb_variant = cfg.keyboard.variant;
        kb_options = cfg.keyboard.options;

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
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
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
        drop_shadow = true;
        shadow_range = 15;
        shadow_render_power = 3;
        "col.shadow" = "rgba(0000001a)";
      };

      # Window layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
        force_split = 2;
      };

      # Miscellaneous configurations
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        enable_swallow = true;
        swallow_regex = "^(Alacritty)$";
      };

      # Startup applications - using common utilities from wayland-wm module
      exec-once = [
        "waybar"
        "swaync"
      ];

      # Window rules
      windowrule = [
        "float,^(pavucontrol)$"
        "float,^(nm-connection-editor)$"
        "float,^(wlogout)$"
        "float,title:^(Picture-in-Picture)$"
        "pin,title:^(Picture-in-Picture)$"
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
        "SUPER, F, fullscreen,"
        "SUPER, P, pseudo,"
        "SUPER, J, togglesplit,"

        # Window focus navigation
        "SUPER, Left, movefocus, l"
        "SUPER, Right, movefocus, r"
        "SUPER, Up, movefocus, u"
        "SUPER, Down, movefocus, d"
        "SUPER, H, movefocus, l"
        "SUPER, L, movefocus, r"
        "SUPER, K, movefocus, u"
        "SUPER, J, movefocus, d"

        # Window move
        "SUPER SHIFT, Left, movewindow, l"
        "SUPER SHIFT, Right, movewindow, r"
        "SUPER SHIFT, Up, movewindow, u"
        "SUPER SHIFT, Down, movewindow, d"
        "SUPER SHIFT, H, movewindow, l"
        "SUPER SHIFT, L, movewindow, r"
        "SUPER SHIFT, K, movewindow, u"
        "SUPER SHIFT, J, movewindow, d"

        # Window resize
        "SUPER ALT, Left, resizeactive, -20 0"
        "SUPER ALT, Right, resizeactive, 20 0"
        "SUPER ALT, Up, resizeactive, 0 -20"
        "SUPER ALT, Down, resizeactive, 0 20"
        "SUPER ALT, H, resizeactive, -20 0"
        "SUPER ALT, L, resizeactive, 20 0"
        "SUPER ALT, K, resizeactive, 0 -20"
        "SUPER ALT, J, resizeactive, 0 20"

        # Window/application navigation
        "ALT, Tab, cyclenext,"
        "ALT SHIFT, Tab, cyclenext, prev"

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
        "SUPER, Page_Down, workspace, e+1"
        "SUPER, Page_Up, workspace, e-1"

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
        "SUPER SHIFT, Page_Down, movetoworkspace, e+1"
        "SUPER SHIFT, Page_Up, movetoworkspace, e-1"

        # Screenshots
        "SUPER SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
        ", Print, exec, grim - | wl-copy"
        "SHIFT, Print, exec, grim -g \"$(slurp)\" - | wl-copy"

        # Logout menu (using common wlogout from wayland-wm module)
        "SUPER, Escape, exec, wlogout"
      ];

      # Mouse bindings
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
  };
}
