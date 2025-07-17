# modules/system/desktop/gnome.nix
{pkgs, ...}: {
  services.desktopManager.gnome.enable = true;
  # System gnome packages
  environment.systemPackages = (
    with pkgs; [
      dconf-editor
      adwaita-icon-theme
      gnome-themes-extra
      gnome-shell-extensions
      gnome-extension-manager
      gnome-tweaks
      gtk3
      gsettings-desktop-schemas
      gnome-online-accounts
      gnome-online-accounts-gtk
    ]
  );
  environment.gnome.excludePackages = (
    with pkgs; [
      gnome-tour
      epiphany
      geary
      totem
      gnome-music
      tali
      iagno
      hitori
      atomix
    ]
  );

  # Enable GVFS for file access
  services.gvfs.enable = true;
}
