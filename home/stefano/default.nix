# home/stefano/default.nix
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../default.nix
    ../../modules/home/syncthing.nix
    ../../modules/home/desktop-apps.nix
    ../../modules/home/dev-tools.nix
  ];

  # User
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";


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
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };


  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    amule # Peer-to-peer client for the eD2K and Kademlia networks
  ];

  home.stateVersion = "23.11";
}
