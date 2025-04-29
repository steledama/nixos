# modules/home/hyprland/swaync.nix
{ config, pkgs, lib, ... }:

{
  # Installa SwayNC
  home.packages = with pkgs; [
    swaynotificationcenter
    libnotify
  ];

  # Configurazione base minima
  xdg.configFile = {
    # Configurazione principale di SwayNC
    "swaync/config.json".text = builtins.toJSON {
      "$schema" = "/etc/xdg/swaync/configSchema.json";
      
      # Opzioni di base del centro notifiche
      "positionX" = "right";
      "positionY" = "top";
      "layer" = "overlay";
      "timeout" = 10;
      "timeout-low" = 5;
      "timeout-critical" = 0;
      "notification-window-width" = 400;
      
      # Widget del centro notifiche
      "widgets" = [
        "title"
        "notifications"
        "buttons-grid"
      ];
      
      # Pulsanti rapidi
      "widgets-config" = {
        "buttons-grid" = {
          "actions" = [
            {
              "label" = "Non disturbare";
              "command" = "swaync-client -t -sw";
            }
            {
              "label" = "Pulisci";
              "command" = "swaync-client -C";
            }
          ];
        };
      };
    };
  };
}
