# nixos/modules/home/zoxide.nix

{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    options = [
      # Other configs es.:
      # "--cmd cd"
    ];
  };
}
