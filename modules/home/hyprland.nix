# modules/home/hyprland.nix
{
  config,
  lib,
  ...
}: let
  cfg = config.wm;
in {
  # Make sure the base is enabled
  config = {
    # Hyprland configuration
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
          # Use the first monitor's wallpaper settings
          "${lib.optionalString (builtins.length cfg.monitors > 0)
            "swaybg -m ${(builtins.elemAt cfg.monitors 0).wallpaper.mode} -i ${(builtins.elemAt cfg.monitors 0).wallpaper.path}"}"
        ];

        # Keyboard shortcuts
        bind = [
          # Basic applications - Matched with Niri
          "SUPER, M, exec, alacritty"
          "SUPER, A, exec, fuzzel"
          "SUPER, N, exec, swaync-client -t -sw"
          "SUPER, L, exec, screen-locker"
          "SUPER, Escape, exec, wlogout"

          # Additional applications
          "SUPER, B, exec, firefox"
          "SUPER, E, exec, nautilus"

          # Window controls
          "SUPER, BackSpace, killactive,"
          "SUPER, Space, togglefloating,"
          "SUPER, F, fullscreen,"
          "SUPER SHIFT, F, fullscreen, 1"
          "SUPER, V, togglefloating,"

          # Window focus navigation - Arrow keys
          "SUPER, Left, movefocus, l"
          "SUPER, Right, movefocus, r"
          "SUPER, Up, movefocus, u"
          "SUPER, Down, movefocus, d"

          # Window movement - Controls + Arrow Keys
          "SUPER CTRL, Left, movewindow, l"
          "SUPER CTRL, Right, movewindow, r"
          "SUPER CTRL, Up, movewindow, u"
          "SUPER CTRL, Down, movewindow, d"

          # Monitor control - Shift + Arrow Keys
          "SUPER SHIFT, Left, focusmonitor, l"
          "SUPER SHIFT, Right, focusmonitor, r"
          "SUPER SHIFT, Up, focusmonitor, u"
          "SUPER SHIFT, Down, focusmonitor, d"

          # Move to monitor - Shift + Ctrl + Arrow Keys
          "SUPER SHIFT CTRL, Left, movecurrentworkspacetomonitor, l"
          "SUPER SHIFT CTRL, Right, movecurrentworkspacetomonitor, r"
          "SUPER SHIFT CTRL, Up, movecurrentworkspacetomonitor, u"
          "SUPER SHIFT CTRL, Down, movecurrentworkspacetomonitor, d"

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
          "SUPER, Page_Down, workspace, e+1"
          "SUPER, Page_Up, workspace, e-1"

          # Moving windows between workspaces - Ctrl + Number
          "SUPER CTRL, 1, movetoworkspace, 1"
          "SUPER CTRL, 2, movetoworkspace, 2"
          "SUPER CTRL, 3, movetoworkspace, 3"
          "SUPER CTRL, 4, movetoworkspace, 4"
          "SUPER CTRL, 5, movetoworkspace, 5"
          "SUPER CTRL, 6, movetoworkspace, 6"
          "SUPER CTRL, 7, movetoworkspace, 7"
          "SUPER CTRL, 8, movetoworkspace, 8"
          "SUPER CTRL, 9, movetoworkspace, 9"

          # Move to workspace with Page Up/Down
          "SUPER CTRL, Page_Down, movetoworkspace, e+1"
          "SUPER CTRL, Page_Up, movetoworkspace, e-1"

          # Window resize
          "SUPER ALT, Left, resizeactive, -20 0"
          "SUPER ALT, Right, resizeactive, 20 0"
          "SUPER ALT, Up, resizeactive, 0 -20"
          "SUPER ALT, Down, resizeactive, 0 20"

          # Size adjustments
          "SUPER, minus, splitratio, -0.1"
          "SUPER, equal, splitratio, 0.1"

          # Screenshots
          "PRINT, exec, grim - | wl-copy"
          "CTRL PRINT, exec, grim -o $(hyprctl activemonitor -j | jq -r '.name') - | wl-copy" # Screenshot current screen
          "ALT PRINT, exec, grim -g \"$(hyprctl activewindow -j | jq -r '\"0,\(.at[1]),\(.size[0]),\(.size[1])\"')\" - | wl-copy" # Screenshot current window
          "SUPER SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy" # Interactive screenshot selection

          # Turn off monitor
          "SUPER SHIFT, P, exec, hyprctl dispatch dpms off"

          # System
          "SUPER ALT, E, exit,"
          "CTRL ALT, Delete, exit,"
        ];

        # Media keys
        bindel = [
          # Volume controls
          "XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+"
          "XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
          "XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

          # Brightness controls
          "XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          "XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ];

        bindle = [
          # Fine-grained brightness controls with Shift
          "SHIFT XF86MonBrightnessUp, exec, brightnessctl set 1%+"
          "SHIFT XF86MonBrightnessDown, exec, brightnessctl set 1%-"
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
