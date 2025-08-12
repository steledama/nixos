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
    ../../modules/home/desktop-apps.nix
    ../../modules/home/dev-tools.nix
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

  # SSH Configuration
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "srv-norvegia" = {
        hostname = "5.89.62.125";
        user = "acquisti";
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          SetEnv = "TERM=xterm-256color";
        };
      };
      "github-tt" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_tt";
        extraOptions = {
          IdentitiesOnly = "yes";
        };
      };
    };
  };

  # SSH public keys (generated from private keys)
  home.file.".ssh/id_ed25519.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICslyKnf1VSpbP5Yq7mzghnxYFCCwzfeIvrxQVDwwQ89 stefano.pompa@gmail.com";
  home.file.".ssh/id_ed25519_tt.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAO0muJh32sg6/lsySvxoXSfUXekrLgI0uvmlmwwbTFaI stefano.pompa@gmail.com";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    amule # Peer-to-peer client for the eD2K and Kademlia networks
  ];

  home.stateVersion = "23.11";
}
