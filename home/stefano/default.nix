# home/stefano/default.nix
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../default.nix
    ../../modules/home/wm.nix
    ../../modules/home/hyprland.nix
    ../../modules/home/niri.nix
  ];

  # User
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";

  # Setup WMs
  wm = {
    keyboard = {
      layout = "it";
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
    amule
  ];

  home.stateVersion = "23.11";
}
