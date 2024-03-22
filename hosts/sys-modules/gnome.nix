{ pkgs, config, ... }:

{
  # Enable the kde Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;

  # include
  environment.systemPackages = with pkgs; [
    # gnome.adwaita-icon-theme
  ];

  # excluding some applications from the default install
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos # photo
    gnome-tour # presentation tour
    gedit # text editor
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music # music
    # gnome-terminal # terminal
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters # fonts
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);
}

