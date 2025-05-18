# modules/system/services/xdg-portals.nix
{pkgs, ...}: {
  # Core XDG portal functionality
  xdg.portal = {
    enable = true;
    # Only include the absolutely necessary portal implementation
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Essential D-Bus service
  services.dbus.enable = true;

  # Basic security policy for authentication dialogs
  security.polkit.enable = true;

  # Minimal required packages
  environment.systemPackages = with pkgs; [
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
  ];
}
