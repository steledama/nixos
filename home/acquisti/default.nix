# nixos/home/acquisti/default.nix
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../default.nix
    ../../modules/home/syncthing.nix
    ../../modules/home/wm.nix
    ../../modules/home/niri.nix
  ];
  # username
  home.username = "acquisti";
  home.homeDirectory = "/home/${config.home.username}";

  # Setup WMs with keyboard configuration
  wayland-wm = {
    enable = true;
    keyboard = {
      layout = "no";
      variant = "";
      options = "";
    };
    wallpaper = {
      imagePath = "$HOME/Immagini/wallpaper.jpg";
      mode = "fill";
    };
  };

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    anydesk # Remote desktop software
  ];

  home.stateVersion = "23.11";
}
