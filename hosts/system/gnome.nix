{ pkgs, config, ... }:

{
  # Enable the kde Desktop Environment.
  services.desktopManager.gnome.enable = true;
  # excluding some applications from the default install
  environment.gnome.excludiePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    gnome-terminal
    gedit # text editor
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);
}

