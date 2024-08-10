{ config, pkgs, ... }:

{

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  imports = [
    ./bindings.nix
  ];

  # Hyprland configuration
  wayland.windowManager.hyprland.extraConfig = ''
    # Start Waybar
    exec-once = waybar

    # Start hyprpaper
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
