# modules/home/hyprland/multimonitor.nix
# Estensione specifica per il supporto multimonitor
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  # Riferimento al modulo base
  baseConfig = config.hyprlandBase.scripts;

  # Script per configurare i monitor
  monitorConfigScript = pkgs.writeShellScriptBin "hyprland-monitor-config" ''
    #!/usr/bin/env bash

    # Monitor configuration script for Hyprland
    # Handles multiple monitor profiles for different setups

    # Get current monitor information
    MONITORS=$(${pkgs.hyprland}/bin/hyprctl monitors -j)
    NUM_MONITORS=$(echo "$MONITORS" | ${pkgs.jq}/bin/jq '. | length')

    # Detect if we're at home (HDMI) or at work (DisplayPort)
    if ${pkgs.coreutils}/bin/cat /sys/class/drm/*/status | ${pkgs.gnugrep}/bin/grep -q "^DP-[0-9] connected"; then
      CONNECTION="DisplayPort"
    elif ${pkgs.coreutils}/bin/cat /sys/class/drm/*/status | ${pkgs.gnugrep}/bin/grep -q "^HDMI-[0-9] connected"; then
      CONNECTION="HDMI"
    else
      CONNECTION="Unknown"
    fi

    # Function to apply monitor configs
    apply_monitor_config() {
      PROFILE="$1"
      case "$PROFILE" in
        "laptop-only")
          # Solo laptop - monitor interno
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,1920x1080,0x0,1"
          ${pkgs.hyprland}/bin/hyprctl keyword monitor ",disable"
          ;;
        "external-only")
          # Solo monitor esterno
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,disable"
          if [ "$CONNECTION" = "DisplayPort" ]; then
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "DP-1,2560x1080,0x0,1"
          else
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "HDMI-A-1,2560x1080,0x0,1"
          fi
          ;;
        "dual-extend")
          # Estensione orizzontale (esterno a sinistra, laptop a destra)
          if [ "$CONNECTION" = "DisplayPort" ]; then
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "DP-1,2560x1080,0x0,1"
          else
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "HDMI-A-1,2560x1080,0x0,1"
          fi
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,1920x1080,2560x0,1"
          ;;
        "dual-mirror")
          # Modalità mirror (stesso contenuto su entrambi)
          ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,1920x1080,0x0,1"
          if [ "$CONNECTION" = "DisplayPort" ]; then
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "DP-1,preferred,0x0,1,mirror,eDP-1"
          else
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "HDMI-A-1,preferred,0x0,1,mirror,eDP-1"
          fi
          ;;
        *)
          echo "Profilo non valido: $PROFILE"
          return 1
          ;;
      esac

      # Dopo aver cambiato configurazione, aggiorna lo sfondo
      ${baseConfig.randomWallpaper}/bin/hyprland-random-wallpaper

      # Notifica l'utente del cambio di profilo
      ${pkgs.libnotify}/bin/notify-send "Monitor" "Profilo $PROFILE applicato ($CONNECTION)"
    }

    # Show profile selector with current status
    select_profile() {
      OPTIONS="laptop-only\nexternal-only\ndual-extend\ndual-mirror"
      SELECTION=$(echo -e "$OPTIONS" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Monitor ($NUM_MONITORS rilevati, $CONNECTION)" --width 300 --height 200 --cache-file /dev/null)

      if [ -n "$SELECTION" ]; then
        apply_monitor_config "$SELECTION"
      fi
    }

    # Main execution
    select_profile
  '';
in {
  # Importiamo il modulo base
  imports = [./base.nix];

  # Aggiungiamo il nuovo script e pacchetti per il multimonitor
  home.packages = [
    monitorConfigScript
    pkgs.jq
    pkgs.brightnessctl
    pkgs.libnotify
  ];

  # Aggiungiamo configurazioni specifiche per il multimonitor
  wayland.windowManager.hyprland.settings = {
    # Rilevamento automatico dei monitor all'avvio
    monitor = [
      "eDP-1,1920x1080,0x0,1" # Monitor laptop integrato
      ",preferred,auto,1" # Configurazione automatica per monitor esterni
    ];

    # Aggiorniamo le scorciatoie con quelle specifiche per i monitor
    bind = [
      # Altre scorciatoie sono ereditate dal modulo base
      "SUPER, P, exec, ${monitorConfigScript}/bin/hyprland-monitor-config"
    ];

    # Miglioramenti per gestione multimonitor
    misc = {
      mouse_move_enables_dpms = true; # Riattiva lo schermo con movimento del mouse
      key_press_enables_dpms = true; # Riattiva lo schermo con pressione tasti
    };
  };
}
