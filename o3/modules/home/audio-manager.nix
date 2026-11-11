# modules/home/audio-manager.nix
# Audio output switcher (HDMI) and Bluetooth device manager for neve
# Launched via .desktop file -> foot with interactive menu
{pkgs, ...}: let
  audio-manager = pkgs.writeShellScriptBin "audio-manager" ''
    CARD="alsa_card.pci-0000_00_1f.3"

    show_status() {
      local profile
      profile=$(${pkgs.pulseaudio}/bin/pactl list cards 2>/dev/null | grep "Profilo attivo:" | head -1)
      if echo "$profile" | grep -q "hdmi-stereo-extra1"; then
        echo "Audio: HDMI 2 (27\")"
      elif echo "$profile" | grep -q "hdmi-stereo"; then
        echo "Audio: HDMI 1 (47\")"
      else
        echo "Audio: altro profilo"
      fi

      local bt_connected
      bt_connected=$(${pkgs.bluez}/bin/bluetoothctl devices Connected 2>/dev/null)
      if [ -n "$bt_connected" ]; then
        echo "Bluetooth: $(echo "$bt_connected" | ${pkgs.gawk}/bin/awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print ""}')"
      else
        echo "Bluetooth: non connesso"
      fi
    }

    set_hdmi() {
      local profile="$1"
      local label="$2"
      ${pkgs.pulseaudio}/bin/pactl set-card-profile "$CARD" "$profile"
      echo ""
      echo "[OK] Audio su $label"
      sleep 1
    }

    bt_connect() {
      # Show known devices first
      local known
      known=$(${pkgs.bluez}/bin/bluetoothctl devices 2>/dev/null)

      if [ -n "$known" ]; then
        echo ""
        echo "Dispositivi noti:"
        echo "$known" | ${pkgs.gawk}/bin/awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print "(" $2 ")"}' | nl -ba
        echo ""
        read -rp "Connetti (numero) o scansiona nuovi (s): " sub
      else
        sub="s"
      fi

      if [ "$sub" = "s" ] || [ "$sub" = "S" ]; then
        echo ""
        echo "Scansione 10 secondi..."
        ${pkgs.bluez}/bin/bluetoothctl --timeout 10 scan on 2>/dev/null
        echo ""
        known=$(${pkgs.bluez}/bin/bluetoothctl devices 2>/dev/null)
        if [ -z "$known" ]; then
          echo "Nessun dispositivo trovato."
          sleep 2
          return
        fi
        echo "Dispositivi trovati:"
        echo "$known" | ${pkgs.gawk}/bin/awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print "(" $2 ")"}' | nl -ba
        echo ""
        read -rp "Numero dispositivo (0 annulla): " sub
      fi

      if [ "$sub" = "0" ] || [ "$sub" = "s" ] || [ "$sub" = "S" ] || [ -z "$sub" ]; then
        return
      fi

      local device name
      device=$(echo "$known" | ${pkgs.coreutils}/bin/sed -n "''${sub}p" | ${pkgs.gawk}/bin/awk '{print $2}')
      name=$(echo "$known" | ${pkgs.coreutils}/bin/sed -n "''${sub}p" | ${pkgs.gawk}/bin/awk '{for(i=3;i<=NF;i++) printf "%s ", $i}')

      if [ -n "$device" ]; then
        echo "Connessione a $name..."
        ${pkgs.bluez}/bin/bluetoothctl pair "$device" 2>/dev/null
        ${pkgs.bluez}/bin/bluetoothctl trust "$device" 2>/dev/null
        ${pkgs.bluez}/bin/bluetoothctl connect "$device" 2>/dev/null
        sleep 1
        if ${pkgs.bluez}/bin/bluetoothctl devices Connected 2>/dev/null | grep -q "$device"; then
          echo "[OK] Connesso a $name"
        else
          echo "[ERRORE] Connessione fallita"
        fi
      fi
      sleep 2
    }

    bt_disconnect() {
      local connected
      connected=$(${pkgs.bluez}/bin/bluetoothctl devices Connected 2>/dev/null)
      if [ -z "$connected" ]; then
        echo ""
        echo "Nessun dispositivo connesso."
        sleep 1
        return
      fi

      echo ""
      echo "Dispositivi connessi:"
      echo "$connected" | ${pkgs.gawk}/bin/awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print "(" $2 ")"}' | nl -ba
      echo ""
      read -rp "Numero da disconnettere (0 annulla): " sub

      if [ "$sub" != "0" ] && [ -n "$sub" ]; then
        local device
        device=$(echo "$connected" | ${pkgs.coreutils}/bin/sed -n "''${sub}p" | ${pkgs.gawk}/bin/awk '{print $2}')
        if [ -n "$device" ]; then
          ${pkgs.bluez}/bin/bluetoothctl disconnect "$device" 2>/dev/null
          echo "[OK] Disconnesso"
        fi
      fi
      sleep 1
    }

    while true; do
      clear
      echo "==================================="
      echo "        Audio Manager - neve"
      echo "==================================="
      echo ""
      show_status
      echo ""
      echo "-- Uscita audio -------------------"
      echo "  1) HDMI 1 - Schermo 47\""
      echo "  2) HDMI 2 - Schermo 27\""
      echo ""
      echo "-- Bluetooth ----------------------"
      echo "  3) Connetti dispositivo BT"
      echo "  4) Disconnetti dispositivo BT"
      echo ""
      echo "  0) Esci"
      echo ""
      read -rp "Scelta: " choice

      case $choice in
        1) set_hdmi "output:hdmi-stereo+input:analog-stereo" "HDMI 1 (47\")" ;;
        2) set_hdmi "output:hdmi-stereo-extra1+input:analog-stereo" "HDMI 2 (27\")" ;;
        3) bt_connect ;;
        4) bt_disconnect ;;
        0) exit 0 ;;
        *) echo "Scelta non valida"; sleep 1 ;;
      esac
    done
  '';
in {
  home.packages = [audio-manager];

  xdg.desktopEntries.audio-manager = {
    name = "Audio Manager";
    comment = "Cambia uscita audio HDMI e gestisci dispositivi Bluetooth";
    exec = "foot -e ${audio-manager}/bin/audio-manager";
    icon = "audio-volume-high-symbolic";
    terminal = false;
    categories = ["AudioVideo" "Audio" "Settings"];
  };
}
