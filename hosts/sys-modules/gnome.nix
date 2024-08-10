{ pkgs, config, ... }:

{
  services.xserver = {
    enable = true;
    # Italian keyboard
    xkb.layout = "it";
    xkb.variant = "";
    # Gdm display manager
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    # Gnome desktop environment
    desktopManager.gnome.enable = true;
  };

  # Exclude GNOME-specific packages here
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gedit
    epiphany
    # geary
    totem
  ]) ++ (with pkgs.gnome; [
    gnome-music
    tali
    iagno
    hitori
    atomix
  ]);

  # Add system packages here
  environment.systemPackages = (with pkgs; [
    dconf-editor
  ]);
}

