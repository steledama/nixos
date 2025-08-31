# nixos/home/stele/default.nix
{config, ...}: {
  imports = [
    ../default.nix
    ../../modules/home/syncthing.nix
    ../../modules/home/desktop-apps.nix
    ../../modules/home/dev-tools.nix
  ];
  # User
  home.username = "stele";
  home.homeDirectory = "/home/${config.home.username}";


  # SSH Configuration
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "srv-norvegia" = {
        hostname = "5.89.62.125";
        user = "acquisti";
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          SetEnv = "TERM=xterm-256color";
        };
      };
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  # User-specific packages
  # home.packages = with pkgs; [
  # packagename
  # ];

  home.stateVersion = "23.11";
}
