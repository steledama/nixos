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

  # Setup WMs
  wm = {
    keyboard = {
      layout = "no";
      variant = "";
      options = "";
    };
    wallpaper = {
      path = "~/Immagini/wallpaper.jpg";
      mode = "fill";
    };
    screenshots = {
      path = "~/Immagini/Screenshot-%Y%m%d-%H%M%S.png";
    };
  };

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    anydesk # Remote desktop software
  ];

  home.stateVersion = "23.11";
}
