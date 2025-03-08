{ pkgs, ... }:

{
  services.xserver = {
    enable = true;

    # Keyboard
    xkb.layout = "it";
    xkb.variant = "";

    # Display manager GDM
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    # Gnome desktop environment
    desktopManager.gnome.enable = true;
  };

  # System gnome packages
  environment.systemPackages = (
    with pkgs;
    [
      dconf-editor
      adwaita-icon-theme
      gnome-themes-extra
      gnome-shell-extensions
      gnome-extension-manager
    ]
  );
  environment.gnome.excludePackages = (
    with pkgs;
    [
      gnome-tour
      epiphany
      geary
      totem
      gnome-music
      tali
      iagno
      hitori
      atomix
      gnome-console
    ]
  );
}
