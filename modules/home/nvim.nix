# nixos/modules/home/nvim.nix

{
  config,
  lib,
  pkgs,
  nvim-config,
  ...
}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Pacchetti necessari per kickstart.nvim
    extraPackages = with pkgs; [
      # Strumenti essenziali
      ripgrep
      fd
      gcc
      gnumake
      unzip
      curl
      wget

      # Per Telescope
      git

      # LSP e formatter
      nodePackages.typescript-language-server
      nodePackages.prettier
      lua-language-server
      marksman # Markdown language server
      nil # Nix language server
      nixpkgs-fmt
    ];
  };

  # Crea il link simbolico alla configurazione esterna
  home.file.".config/nvim" = {
    source = nvim-config;
  };

  # Installa dipendenze addizionali specifiche per linguaggi
  home.packages = with pkgs; [
    # python
    nodePackages.pyright # Python LSP
    python311Packages.black # Python formatter

    # js/ts
    nodePackages.eslint

    # Altri strumenti utili per Neovim
    lazygit # Per un'interfaccia Git TUI
  ];
}
