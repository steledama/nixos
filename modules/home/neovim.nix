# nixos/modules/home/nvim.nix
{
  config,
  lib,
  pkgs,
  neovim-config,
  ...
}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Symbolic link to external config from repo
  home.file.".config/nvim" = {
    source = neovim-config;
  };

  # Packages directly linked to neovim
  home.packages = with pkgs; [
    markdownlint-cli
  ];
}
