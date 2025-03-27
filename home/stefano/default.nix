# nixos/home/stefano/default.nix
{
  config,
  pkgs,
  neovim-config,
  ...
}: {
  imports = [
    ../default.nix
  ];

  # username
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    amule
  ];

  home.stateVersion = "23.11";
}
