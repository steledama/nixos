# modules/home/openrgb-tray.nix
# GUI di OpenRGB all'avvio, ridotta nel tray di Noctalia. Il server SDK è
# di sistema (modules/system/hardware/openrgb.nix) e la GUI vi si collega
# da sola come client. Sostituisce l'autostart XDG che OpenRGB scrive da sé
# in ~/.config/autostart, legato a un path dello store che invecchia.
{...}: let
  # Binario di sistema: come per noctalia in niri.nix, niente seconda copia
  # nella closure home.
  openrgb = "/run/current-system/sw/bin/openrgb";
in {
  systemd.user.services.openrgb-tray = {
    Unit = {
      Description = "OpenRGB GUI nel tray";
      PartOf = "graphical-session.target";
      After = ["graphical-session.target" "noctalia.service"];
    };
    Install.WantedBy = ["graphical-session.target"];
    Service = {
      # Senza tray Qt mostrerebbe la finestra: aspetta il watcher di
      # Noctalia (massimo 30 s), poi parte comunque.
      ExecStartPre = "/run/current-system/sw/bin/sh -c 'for i in $(/run/current-system/sw/bin/seq 60); do /run/current-system/sw/bin/busctl --user status org.kde.StatusNotifierWatcher >/dev/null 2>&1 && exit 0; /run/current-system/sw/bin/sleep 0.5; done; exit 0'";
      ExecStart = "${openrgb} --startminimized";
      Restart = "on-failure";
      RestartSec = "3s";
    };
  };
}
