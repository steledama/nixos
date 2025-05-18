# modules/system/desktop/gnome.nix
{pkgs, ...}: {
  services.xserver.desktopManager.gnome.enable = true;

  # Core packages only
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-terminal
    gtk3
    gsettings-desktop-schemas
    gnome-online-accounts
    gnome-online-accounts-gtk
  ];

  # Enable GVFS for file access
  services.gvfs.enable = true;
}
