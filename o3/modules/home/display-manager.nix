# modules/home/display-manager.nix
# Display manager per neve: abilita/disabilita il secondo schermo (47" 4K)
# Launched via .desktop file -> foot con menu interattivo
{pkgs, ...}: let
  display-manager = pkgs.writeShellScriptBin "display-manager" ''
    set -u

    HDMI_PRIMARY="HDMI-A-2"   # 27" FHD (schermo principale)
    HDMI_SECONDARY="HDMI-A-1" # 47" 4K (TV soggiorno)
    WLR_RANDR="${pkgs.wlr-randr}/bin/wlr-randr"
    SLEEP="${pkgs.coreutils}/bin/sleep"

    usage() {
      echo "Uso: display-manager [dual|solo27|solo47|status]"
    }

    get_output_status() {
      local connector="$1"
      local info

      info=$($WLR_RANDR 2>/dev/null | ${pkgs.gawk}/bin/awk -v conn="$connector" '
        $0 ~ "^"conn" " { found=1; next }
        found && /^[^ ]/ { exit }
        found && /Enabled:/ { print $2; exit }
      ')

      if [ -z "$info" ]; then
        echo "non rilevato"
      elif [ "$info" = "yes" ]; then
        local mode
        mode=$($WLR_RANDR 2>/dev/null | ${pkgs.gawk}/bin/awk -v conn="$connector" '
          $0 ~ "^"conn" " { found=1; next }
          found && /^[^ ]/ { exit }
          found && /\(current\)/ { gsub(/[[:space:]].*/, "", $1); print $1; exit }
        ')
        echo "acceso''${mode:+ - $mode}"
      else
        echo "spento"
      fi
    }

    show_status() {
      echo "27\" FHD  ($HDMI_PRIMARY): $(get_output_status "$HDMI_PRIMARY")"
      echo "47\" 4K   ($HDMI_SECONDARY): $(get_output_status "$HDMI_SECONDARY")"
    }

    wait_for_outputs() {
      local attempts=20

      while [ "$attempts" -gt 0 ]; do
        if $WLR_RANDR 2>/dev/null | ${pkgs.gnugrep}/bin/grep -q "^$HDMI_PRIMARY "; then
          return 0
        fi

        attempts=$((attempts - 1))
        $SLEEP 0.5
      done

      echo "[ERRORE] Output $HDMI_PRIMARY non rilevato da wlr-randr" >&2
      return 1
    }

    set_mode() {
      local mode="$1"
      wait_for_outputs || return 1

      case "$mode" in
        dual)
          if ! $WLR_RANDR \
            --output "$HDMI_PRIMARY" --on --preferred --pos 0,0 \
            --output "$HDMI_SECONDARY" --on --preferred --right-of "$HDMI_PRIMARY"; then
            echo "[ERRORE] Impossibile attivare il profilo dual" >&2
            return 1
          fi
          echo ""
          echo "[OK] Dual monitor attivo"
          ;;
        solo27)
          if ! $WLR_RANDR \
            --output "$HDMI_PRIMARY" --on --preferred --pos 0,0 \
            --output "$HDMI_SECONDARY" --off; then
            echo "[ERRORE] Impossibile attivare il profilo solo 27\"" >&2
            return 1
          fi
          echo ""
          echo "[OK] Solo 27\" FHD"
          ;;
        solo47)
          if ! $WLR_RANDR \
            --output "$HDMI_SECONDARY" --on --preferred --pos 0,0 \
            --output "$HDMI_PRIMARY" --off; then
            echo "[ERRORE] Impossibile attivare il profilo solo 47\"" >&2
            return 1
          fi
          echo ""
          echo "[OK] Solo 47\" 4K"
          ;;
        *)
          usage
          exit 2
          ;;
      esac
      $SLEEP 1
    }

    if [ "$#" -gt 0 ]; then
      case "$1" in
        dual|solo27|solo47) set_mode "$1" ;;
        status) show_status ;;
        -h|--help|help) usage ;;
        *) usage; exit 2 ;;
      esac
      exit 0
    fi

    while true; do
      ${pkgs.ncurses}/bin/clear
      echo "==================================="
      echo "       Display Manager - neve"
      echo "==================================="
      echo ""
      show_status
      echo ""
      echo "-- Configurazione -----------------"
      echo "  1) Dual monitor (27\" + 47\")"
      echo "  2) Solo 27\" FHD (spegni 47\")"
      echo "  3) Solo 47\" 4K (accendi 47\")"
      echo ""
      echo "  0) Esci"
      echo ""
      read -rp "Scelta: " choice

      case $choice in
        1) set_mode dual ;;
        2) set_mode solo27 ;;
        3) set_mode solo47 ;;
        0) exit 0 ;;
        *) echo "Scelta non valida"; $SLEEP 1 ;;
      esac
    done
  '';
in {
  home.packages = [display-manager pkgs.wlr-randr];

  xdg.desktopEntries.display-manager = {
    name = "Display Manager";
    comment = "Abilita o disabilita il secondo schermo (47\" 4K)";
    exec = "foot -e ${display-manager}/bin/display-manager";
    icon = "video-display-symbolic";
    terminal = false;
    categories = ["Settings" "HardwareSettings"];
  };
}
