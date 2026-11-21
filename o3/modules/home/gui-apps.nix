# modules/home/gui-apps.nix
# App grafiche dell'utente, a home per criterio di livello
# (kb/configuration-patterns.md, «Pacchetti: un solo livello»): non chiedono
# privilegi né integrazione col sistema, si aggiornano senza sudo e tornano
# indietro con la generazione home. Le loro configurazioni vivono nei moduli
# dedicati (zed.nix, mimeapps in o3/home/default.nix). foot resta a system
# come terminale di soccorso (modules/system/gui-apps.nix).
{pkgs, ...}: {
  # UNFREE: chromium + chromium-unwrapped + widevine-cdm (enableWideVine
  # rende unfree anche chromium, la cui base è BSD-3)
  unfree.allowedNames = [
    "chromium"
    "chromium-unwrapped"
    "widevine-cdm"
  ];

  home.packages = with pkgs; [
    # Editor
    zed-editor

    # Browser with DRM (Widevine) for streaming services
    (chromium.override {enableWideVine = true;})

    # Productivity
    gnumeric # Lightweight spreadsheet
    abiword # Lightweight word processor
    inkscape # Vector graphics editor

    # Utilities
    seahorse # GNOME keyring manager (il keyring è un servizio di sistema, niri.nix)
    usbimager # OS image USB flasher (scrive tramite udisks2, servizio di sistema)

    # Media
    mpv # Video player (reliable hw/sw decoding)

    # Lightweight viewers
    imv # Image viewer for Wayland/X11
    zathura # Lightweight document viewer
  ];
}
