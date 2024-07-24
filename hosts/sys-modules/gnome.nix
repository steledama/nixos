{ pkgs, config, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
  };

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    gedit
    epiphany
    geary
    totem
  ]) ++ (with pkgs.gnome; [
    gnome-music
    tali
    iagno
    hitori
    atomix
  ]);

  environment.systemPackages = with pkgs; [
    # Add any additional GNOME-specific packages here
  ];
}

