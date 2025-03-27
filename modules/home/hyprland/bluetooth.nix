# modules/home/hyprland/bluetooth.nix
# Estensione specifica per il supporto bluetooth in Hyprland
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  # Importiamo il modulo base
  imports = [./base.nix];

  # Aggiungiamo pacchetti utili per bluetooth
  home.packages = with pkgs; [
    blueman
    bluez-tools
  ];

  # Aggiungiamo esecuzioni specifiche per bluetooth
  wayland.windowManager.hyprland.settings = {
    # Esecuzione del blueman-applet all'avvio
    exec-once = [
      "blueman-applet" # Bluetooth applet
    ];

    # Regole per le finestre bluetooth
    windowrulev2 = [
      "float,class:^(blueman-manager)$"
      "center,class:^(blueman-manager)$"
    ];
  };

  # Estensione waybar per bluetooth
  programs.waybar.settings = {
    mainBar = {
      # Aggiungiamo bluetooth tra i moduli a destra
      modules-right = ["custom/keymap" "bluetooth" "pulseaudio" "network" "battery" "tray"];

      # Configurazione del modulo bluetooth
      "bluetooth" = {
        format = " {status}";
        format-connected = " {device_alias}";
        format-connected-battery = " {device_alias} {device_battery_percentage}%";
        tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
        tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
        on-click = "blueman-manager";
      };
    };
  };

  # Stile CSS per il modulo Bluetooth
  programs.waybar.style = lib.mkAfter ''
    /* Stile per il modulo bluetooth */
    #bluetooth {
      color: #61afef;
    }
    #bluetooth.connected {
      color: #98c379;
    }
    #bluetooth.disconnected {
      color: #e06c75;
    }

    #bluetooth:hover {
      background-color: rgba(97, 175, 239, 0.2);
      border-radius: 5px;
    }
  '';
}
