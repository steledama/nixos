# modules/system/gui-apps.nix
# System-level GUI applications
# Imported by the baseline o3/hosts/default.nix: every host is a desktop.
{pkgs, ...}: {
  config = {
    # UNFREE: chromium + chromium-unwrapped + widevine-cdm (enableWideVine
    # rende unfree anche chromium, la cui base è BSD-3)
    unfree.allowedNames = [
      "chromium"
      "chromium-unwrapped"
      "widevine-cdm"
    ];

    # Foot terminal: il pacchetto vive qui (GUI = system-level); le preferenze
    # utente vivono nel modulo home niri (kb/configuration-patterns.md).
    # Registra foot come terminale predefinito per xdg-terminal-exec
    environment.etc."xdg/xdg-terminals.list".text = "foot.desktop\n";

    environment.systemPackages = with pkgs; [
      # Terminal
      foot # Fast standalone Wayland terminal
      xdg-terminal-exec # Handles Terminal=true desktop entries

      # Editor
      zed-editor

      # Browser with DRM (Widevine) for streaming services
      # UNFREE: requires allowUnfreePredicate for "chromium", "chromium-unwrapped" and "widevine-cdm"
      # Note: chromium base is BSD-3, but enableWideVine override makes all three unfree
      (chromium.override {enableWideVine = true;})

      # Productivity
      gnumeric # Lightweight spreadsheet
      abiword # Lightweight word processor
      inkscape # Vector graphics editor

      # Utilities
      seahorse # GNOME keyring manager
      usbimager # OS image USB flasher

      # Media
      mpv # Video player (reliable hw/sw decoding, replaces COSMIC Player)

      # Lightweight viewers
      imv # Image viewer for Wayland/X11
      zathura # Lightweight document viewer
    ];
  };
}
