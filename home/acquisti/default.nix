# nixos/home/acquisti/default.nix
{config, ...}: {
  imports = [
    ../default.nix
    ../../modules/home/syncthing.nix
  ];
  # username
  home.username = "acquisti";
  home.homeDirectory = "/home/${config.home.username}";

  home.stateVersion = "23.11";
}
