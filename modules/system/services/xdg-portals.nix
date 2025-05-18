# modules/system/services/xdg-portals.nix
{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
  services.dbus.enable = true;
  environment.systemPackages = with pkgs; [
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
  ];
}
