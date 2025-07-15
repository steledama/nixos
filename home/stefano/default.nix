# home/stefano/default.nix
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../default.nix
    ../../modules/home/wm.nix
    ../../modules/home/waybar.nix
    ../../modules/home/hyprland.nix
    ../../modules/home/niri.nix
    ../../modules/home/syncthing.nix
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
    monitors = [
      {
        name = "DP-3";
        mode = {
          width = 2560;
          height = 1080;
        };
        position = {
          x = 0;
          y = 0;
        };
        scale = 1.0;
        transform = "normal";
        wallpaper = {
          path = "~/Immagini/wallpaper.jpg";
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
    amule # Peer-to-peer client for the eD2K and Kademlia networks
    gimp # Image manipulation program
  ];

  home.stateVersion = "23.11";
}
