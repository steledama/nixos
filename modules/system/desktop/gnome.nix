# modules/system/desktop/gnome.nix
{pkgs, ...}: {
  services.xserver.desktopManager.gnome.enable = true;
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-terminal
    gtk3
    gsettings-desktop-schemas
  ];
  services.gvfs.enable = true;
}
