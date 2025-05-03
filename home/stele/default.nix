# nixos/home/stele/default.nix
{config, ...}: {
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
    monitors = [
      # External monitor
      {
        name = "DP-2"; # run 'wlr-randr' for yours display names
        mode = {
          width = 1920;
          height = 1080;
        };
        position = {
          x = 0;
          y = 0;
        };
        scale = 1.0;
        transform = "normal";
        wallpaper = {
          path = "~/Immagini/wallpaper-ext.jpg";
          mode = "fill";
        };
      }
      # Internal monitor (rotated)
      {
        name = "DSI-1"; # run 'wlr-randr' for yours display names
        mode = {
          width = 1200;
          height = 1920;
        };
        position = {
          x = 0;
          y = 1080;
        };
        scale = 1.5;
        transform = "270";
        wallpaper = {
          path = "~/Immagini/wallpaper-int.jpg";
          mode = "fill";
        };
      }
    ];
    screenshots = {
      path = "~/Immagini/Schermate/Screenshot-%Y%m%d-%H%M%S.png";
    };
  };

  # User-specific packages (additional to common ones)
  # home.packages = with pkgs; [
  # ];

  home.stateVersion = "23.11";
}
