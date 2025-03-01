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

  # Crea il link simbolico alla configurazione esterna
  home.file.".config/nvim" = {
    source = neovim-config;
  };
}
