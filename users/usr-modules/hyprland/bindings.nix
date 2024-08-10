{ config, pkgs, ... }:

let
  # Definisci qui i tuoi binding
  bindings = {
    "ALT, F4" = "killactive";
    "SUPER, Up" = "fullscreen";
    "SUPER, Left" = "movewindow, l";
    "SUPER, Right" = "movewindow, r";
    "SUPER, E" = "exec, nautilus";
    "SUPER, B" = "exec, chromium";
    "ALT, Tab" = "cyclenext";
    "ALT, code:51" = "cyclenext, prev";
    "CTRL SUPER, Right" = "workspace, +1";
    "CTRL SUPER, Left" = "workspace, -1";
    "ALT CTRL SUPER, Right" = "movetoworkspace, +1";
    "ALT CTRL SUPER, Left" = "movetoworkspace, -1";
    "ALT CTRL SUPER, Up" = "movecurrentworkspacetomonitor, u";
    "ALT CTRL SUPER, Down" = "movecurrentworkspacetomonitor, d";
    "SHIFT SUPER, S" = "exec, screenshot-area";
    ", Print" = "exec, screenshot-full";
    "ALT, Print" = "exec, screenshot-window";
    "SUPER, R" = "exec, wofi --show drun";
    "SUPER, Tab" = "workspace, previous";
    "SUPER, T" = "exec, alacritty";
    "CTRL, Left" = "movefocus, l";
    "CTRL, Right" = "movefocus, r";
    "CTRL, Up" = "movefocus, u";
    "CTRL, Down" = "movefocus, d";
    "SUPER, X" = "exec, wlogout";
    "SUPER, V" = "exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy";

    # Workspace bindings
    "SUPER, 1" = "workspace, 1";
    "SUPER, 2" = "workspace, 2";
    "SUPER, 3" = "workspace, 3";
    "SUPER, 4" = "workspace, 4";
    "SUPER, 5" = "workspace, 5";
    "SUPER, 6" = "workspace, 6";
    "SUPER, 7" = "workspace, 7";
    "SUPER, 8" = "workspace, 8";
    "SUPER, 9" = "workspace, 9";
    "SUPER, 0" = "workspace, 10";
  };

  # Funzione per generare il comando che mostra i binding
  generateBindingsScript = pkgs.writeShellScriptBin "show-hypr-bindings" ''
    echo "Hyprland Keybindings:" > /tmp/hypr_bindings
    ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (binding: command: 
      ''echo "${binding} = ${command}" >> /tmp/hypr_bindings''
    ) bindings))}
    cat /tmp/hypr_bindings | wofi --dmenu
  '';

in
{
  wayland.windowManager.hyprland = {
    extraConfig = builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs
      (binding: command:
        "bind = ${binding},${command}"
      )
      bindings));
  };

  home.packages = [ generateBindingsScript ];
}
