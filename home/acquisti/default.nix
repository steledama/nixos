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
    ../../modules/home/waybar.nix
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
  home.packages = with pkgs; [
    anydesk # Remote desktop software
  ];

  home.stateVersion = "23.11";
}
