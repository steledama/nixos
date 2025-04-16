# nixos/home/stele/default.nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../default.nix
  ];
  # username
  home.username = "stele";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
  ];

  home.stateVersion = "23.11";
}
