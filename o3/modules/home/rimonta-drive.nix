# modules/home/rimonta-drive.nix
# Google Drive mount status viewer and remount tool
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Accounts follow the host's rclone mounts, so the menu never lists a
  # Drive the profile does not mount.
  accounts = builtins.attrNames config.services.rcloneMount.mounts;
  displayName = account: let
    n = lib.removePrefix "gdrive-" account;
  in
    lib.toUpper (lib.substring 0 1 n) + lib.substring 1 (-1) n;
  bashArray = xs: lib.concatMapStringsSep " " lib.escapeShellArg xs;

  rimonta-drive = pkgs.writeShellScriptBin "rimonta-drive" ''
    accounts=(${bashArray accounts})
    nomi=(${bashArray (map displayName accounts)})

    clear
    echo "==============================="
    echo "  Google Drive — Stato Mount"
    echo "==============================="
    echo ""

    for i in "''${!accounts[@]}"; do
      account="''${accounts[$i]}"
      nome="''${nomi[$i]}"
      service="rclone-mount-''${account}.service"
      stato=$(systemctl --user is-active "$service" 2>/dev/null)
      printf "  %-10s %s\n" "''${nome}" "''${stato}"
    done

    echo ""
    for i in "''${!nomi[@]}"; do
      echo "  $((i + 1)). ''${nomi[$i]}"
    done
    echo ""
    echo "  Invio = Rimonta tutti"
    echo "  0    = Esci"
    echo ""
    read -p "Scelta [tutti]: " scelta

    if [[ "$scelta" == "0" ]]; then
      exit 0
    elif [[ -z "$scelta" ]]; then
      selezionati=("''${!accounts[@]}")
      echo ""
      echo "Rimontaggio di tutti gli account..."
    elif [[ "$scelta" =~ ^[0-9]+$ ]] && ((scelta <= ''${#accounts[@]})); then
      selezionati=($((scelta - 1)))
      echo ""
      echo "Rimontaggio di ''${nomi[$((scelta - 1))]}..."
    else
      echo ""
      echo "Scelta non valida."
      echo ""
      read -n 1 -s -p "Premi un tasto per chiudere..."
      exit 1
    fi

    echo ""

    errori=0
    for idx in "''${selezionati[@]}"; do
      account="''${accounts[$idx]}"
      nome="''${nomi[$idx]}"
      service="rclone-mount-''${account}.service"

      printf "%-12s" "''${nome}..."

      systemctl --user restart "$service" 2>/dev/null
      sleep 1
      stato=$(systemctl --user is-active "$service" 2>/dev/null)
      if [[ "$stato" == "active" ]]; then
        echo " OK"
      else
        echo " ERRORE (''${stato})"
        ((errori++))
      fi
    done

    echo ""
    if [[ $errori -eq 0 ]]; then
      echo "Tutto montato!"
    else
      echo "Completato con $errori errore/i."
    fi
    echo ""
    read -n 1 -s -p "Premi un tasto per chiudere..."
  '';
in {
  home.packages = [rimonta-drive];

  xdg.desktopEntries.rimonta-drive = {
    name = "Rimonta Google Drive";
    comment = "Stato e rimontaggio Google Drive";
    exec = "foot -e ${rimonta-drive}/bin/rimonta-drive";
    icon = "view-refresh-symbolic";
    terminal = false;
    categories = ["Utility"];
  };
}
