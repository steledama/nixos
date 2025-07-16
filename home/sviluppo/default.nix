# nixos/home/sviluppo/default.nix
{config, ...}: {
  imports = [
    ../default.nix
    ../../modules/home/syncthing.nix
    ../../modules/home/desktop-apps.nix
  ];
  # username
  home.username = "sviluppo";
  home.homeDirectory = "/home/${config.home.username}";

  # Setup WMs
  # wm = {
  #   keyboard = {
  #     layout = "no";
  #     variant = "";
  #     options = "";
  #   };
  #   monitors = [
  #     # External monitor
  #     {
  #       name = "DP-1"; # run 'wlr-randr' for yours display names
  #       mode = {
  #         width = 2560;
  #         height = 1080;
  #       };
  #       position = {
  #         x = 0;
  #         y = 0;
  #       };
  #       scale = 1.0;
  #       transform = "normal";
  #       wallpaper = {
  #         path = "~/Immagini/wallpaper-ext.jpg";
  #         mode = "fill";
  #       };
  #     }
  #     # Internal monitor (rotated)
  #     {
  #       name = "eDP-1"; # run 'wlr-randr' for yours display names
  #       mode = {
  #         width = 1920;
  #         height = 1080;
  #       };
  #       position = {
  #         x = 0;
  #         y = 1080;
  #       };
  #       scale = 1.25;
  #       transform = "normal";
  #       wallpaper = {
  #         path = "~/Immagini/wallpaper-int.jpg";
  #         mode = "fill";
  #       };
  #     }
  #   ];
  #   screenshots = {
  #     path = "~/Immagini/Schermate/Screenshot-%Y%m%d-%H%M%S.png";
  #   };
  # };

  # User-specific packages
  # home.packages = with pkgs; [
  #   packagename
  # ];

  home.stateVersion = "23.11";
}
