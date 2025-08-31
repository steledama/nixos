# nixos/home/acquisti/default.nix
{config, ...}: {
  imports = [
    ../default.nix
    ../../modules/home/syncthing.nix
    ../../modules/home/dev-tools.nix
  ];
  # username
  home.username = "acquisti";
  home.homeDirectory = "/home/${config.home.username}";

  # SSH Configuration
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github-tt" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_tt";
        identitiesOnly = true;
      };
    };
  };

  home.stateVersion = "23.11";
}
