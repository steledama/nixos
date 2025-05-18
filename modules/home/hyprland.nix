# modules/home/hyprland.nix
{
  config,
  lib,
  ...
}: let
  cfg = config.wm;
in {
  config = {
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

        # Window layout
        dwindle = {
          pseudotile = true;
          preserve_split = true;
          force_split = 2;
        };

        # Other Hyprland-specific configurations
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          enable_swallow = true;
          swallow_regex = "^(Alacritty)$";
        };

        # Startup applications
        exec-once = [
          "waybar"
          "swaync"
          "nm-applet --indicator"
          # Use the first monitor's wallpaper settings
          "${lib.optionalString (builtins.length cfg.monitors > 0)
            "swaybg -m ${(builtins.elemAt cfg.monitors 0).wallpaper.mode} -i ${(builtins.elemAt cfg.monitors 0).wallpaper.path}"}"
        ];

        # Keyboard shortcuts
        bind = [
          # Hotkey overlay
          # "SUPER, F1" not implemented

          # System
          "SUPER SHIFT, P, exec, hyprctl dispatch dpms off"
          "SUPER, L, exec, screen-locker"
          "SUPER, Escape, exec, wlogout"
          "CTRL ALT, Delete, exit,"

          # Applications
          "SUPER, A, exec, fuzzel"
          "SUPER, B, exec, firefox"
          "SUPER, E, exec, nautilus"
          "SUPER, G, exec, ghostty"
          "SUPER, M, exec, thunderbird"

          # Window size
          "SUPER, BackSpace, killactive,"
          "SUPER SHIFT, F, fullscreen,"
          "SUPER, plus, resizeactive, -20 0"
          "SUPER, minus, resizeactive, 20 0"
          "SUPER, V, togglefloating,"

          # Alt - Window focus
          "ALT, Tab, cyclenext,"
          "ALT SHIFT, Tab, cyclenext, prev"

          # Mod + Arrow Keys - Window focus
          "SUPER, Left, movefocus, l"
          "SUPER, Right, movefocus, r"
          "SUPER, Up, movefocus, u"
          "SUPER, Down, movefocus, d"

          # Mod + Number - Workspace focus
          "SUPER, 1, workspace, 1"
          "SUPER, 2, workspace, 2"
          "SUPER, 3, workspace, 3"
          "SUPER, 4, workspace, 4"
          "SUPER, 5, workspace, 5"
          "SUPER, 6, workspace, 6"
          "SUPER, 7, workspace, 7"
          "SUPER, 8, workspace, 8"
          "SUPER, 9, workspace, 9"

          # Mod + Ctrl + Arrow Keys - Move window within workspace
          "SUPER CTRL, Left, movewindow, l"
          "SUPER CTRL, Right, movewindow, r"
          "SUPER CTRL, Up, movewindow, u"
          "SUPER CTRL, Down, movewindow, d"

          # Mod + Alt + Arrow Keys - Move window to workspace
          "SUPER ALT, Left, workspace, e-1"
          "SUPER ALT, Right, workspace, e+1"

          # Mod + Ctrl + Alt + Arrow Keys - Move window to workspace
          "SUPER ALT CTRL, Left, movetoworkspace, e-1"
          "SUPER ALT CTRL, Right, movetoworkspace, e+1"

          # Mod + Ctrl + Number - Move window to workspace
          "SUPER CTRL, 1, movetoworkspace, 1"
          "SUPER CTRL, 2, movetoworkspace, 2"
          "SUPER CTRL, 3, movetoworkspace, 3"
          "SUPER CTRL, 4, movetoworkspace, 4"
          "SUPER CTRL, 5, movetoworkspace, 5"
          "SUPER CTRL, 6, movetoworkspace, 6"
          "SUPER CTRL, 7, movetoworkspace, 7"
          "SUPER CTRL, 8, movetoworkspace, 8"
          "SUPER CTRL, 9, movetoworkspace, 9"

          # Mod + Shift + Arrow Keys - Monitor focus
          "SUPER SHIFT, Left, focusmonitor, l"
          "SUPER SHIFT, Right, focusmonitor, r"
          "SUPER SHIFT, Up, focusmonitor, u"
          "SUPER SHIFT, Down, focusmonitor, d"

          # Mod + Ctrl + Shift + Arrow Keys - Move window to monitor
          "SUPER SHIFT CTRL, Left, movewindow, mon:l"
          "SUPER SHIFT CTRL, Right, movewindow, mon:r"
          "SUPER SHIFT CTRL, Up, movewindow, mon:u"
          "SUPER SHIFT CTRL, Down, movewindow, mon:d"
        ];

        # Mouse bindings
        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];
      };
    };
  };
}
