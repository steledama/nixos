{ config, pkgs, ... }:

{
  # home.packages = with pkgs; [
  #   hyprland
  #   xdg-desktop-portal-hyprland
  #   xdg-desktop-portal-gtk
  # ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Basic Hyprland configuration
  wayland.windowManager.hyprland.extraConfig = ''
    # Use GNOME Settings Daemon to manage settings
    exec-once = ${pkgs.gnome.gnome-settings-daemon}/libexec/gnome-settings-daemon

    # Start Waybar
    exec-once = waybar

    # Set wallpaper
    exec-once = hyprpaper

    # Set Italian keyboard layout
    input {
      kb_layout = it
    }

    # General settings
    general {
      gaps_in = 5
      gaps_out = 20
      border_size = 2
      col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
      col.inactive_border = rgba(595959aa)
      layout = dwindle
    }

    # Window rules
    windowrule = float, ^(pavucontrol)$
    windowrule = float, ^(nm-connection-editor)$

    # Shortcuts
    bind = ALT, F4, killactive
    bind = SUPER, Up, fullscreen
    bind = SUPER, Left, movewindow, l
    bind = SUPER, Right, movewindow, r
    bind = SUPER, E, exec, nautilus # Replace with your preferred file explorer
    bind = SUPER, B, exec, chromium # Replace with your preferred terminal
    bind = ALT, Tab, cyclenext
    bind = ALT, code:51, cyclenext, prev # Alt + Backslash
    bind = SUPER, D, exec, hyprctl dispatch workspace e+0
    bind = CTRL SUPER, Right, workspace, +1
    bind = CTRL SUPER, Left, workspace, -1
    bind = ALT CTRL SUPER, Right, movetoworkspace, +1
    bind = ALT CTRL SUPER, Left, movetoworkspace, -1
    bind = ALT CTRL SUPER, Up, movecurrentworkspacetomonitor, u
    bind = ALT CTRL SUPER, Down, movecurrentworkspacetomonitor, d
    bind = SHIFT SUPER, S, exec, screenshot-area
    bind = , Print, exec, screenshot-full
    bind = ALT, Print, exec, screenshot-window
    bind = SUPER, R, exec, wofi --show drun # Use your app launcher
    bind = SUPER, Tab, workspace, previous
    bind = SUPER, T, exec, alacritty # Replace with your preferred terminal
    bind = CTRL, Left, movefocus, l
    bind = CTRL, Right, movefocus, r
    bind = CTRL, Up, movefocus, u
    bind = CTRL, Down, movefocus, d
    bind = SUPER, x, exec, wlogout

    # Bind SUPER + [0-9] to switch to workspace [0-9]
    bind = SUPER, 1, workspace, 1
    bind = SUPER, 2, workspace, 2
    bind = SUPER, 3, workspace, 3
    bind = SUPER, 4, workspace, 4
    bind = SUPER, 5, workspace, 5
    bind = SUPER, 6, workspace, 6
    bind = SUPER, 7, workspace, 7
    bind = SUPER, 8, workspace, 8
    bind = SUPER, 9, workspace, 9
    bind = SUPER, 0, workspace, 10

    # Other default settings (animations, gestures, etc.)
    animations {
      enabled = yes
      bezier = myBezier, 0.05, 0.9, 0.1, 1.05
      animation = windows, 1, 7, myBezier
      animation = windowsOut, 1, 7, default, popin 80%
      animation = border, 1, 10, default
      animation = fade, 1, 7, default
      animation = workspaces, 1, 6, default
    }

    dwindle {
      pseudotile = yes
      preserve_split = yes
    }

    gestures {
      workspace_swipe = off
    }
  '';
}
