# home/stefano/niri-config.nix
# Niri configuration using home-manager
{
  config,
  lib,
  pkgs,
  ...
}: {
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
}
