# nixos/home/stele/default.nix
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../default.nix
    ../../modules/home/wm.nix
    ../../modules/home/niri.nix
  ];
  # User
  home.username = "stele";
  home.homeDirectory = "/home/${config.home.username}";

  # Setup WMs (default us keyboard)
  wm = {
    wallpaper = {
      path = "~/Immagini/wallpaper.jpg";
      mode = "fill";
    };
    screenshots = {
      path = "~/Immagini/Schermate/Screenshot-%Y%m%d-%H%M%S.png";
    };
  };

  # User-specific packages (additional to common ones)
  # home.packages = with pkgs; [
  # ];

  home.stateVersion = "23.11";
}
