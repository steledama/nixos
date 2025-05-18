# modules/system/services/xdg-portals.nix
# Configurazione minima XDG Portal
{pkgs, ...}: {
  # Configurazione base del portale XDG
  xdg.portal = {
    enable = true;

    # Solo il portale di base
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # D-Bus è necessario
  services.dbus.enable = true;

  # Solo alcuni pacchetti essenziali
  environment.systemPackages = with pkgs; [
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
  ];
}
