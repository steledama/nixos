{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "stefano";
  home.homeDirectory = "/home/stefano";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Imports program configuration modules
  imports = [
    # alacritty
    ./usr-modules/alacritty.nix
    # kitty
    ./usr-modules/kitty.nix
    # wezterm
    ./usr-modules/wezterm.nix
    # terminal system info
    ./usr-modules/neofetch.nix
    # bash prompt customization
    ./usr-modules/starship.nix
    # bash aliases and start commands
    ./usr-modules/bash.nix
    # cursor
    ./usr-modules/cursor.nix
    # syncthing
    ./usr-modules/syncthing.nix
  ];

  # allowUnfree packages
  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # browsers
    firefox # personal browser
    brave # work browser

    # graphics
    gimp # pixel design
    inkscape # vector design

    # office
    libreoffice-fresh # open source office suite
    evolution # mail client

    # unfree software
    anydesk # remote dektop
    obsidian # writing and note taking tool
    vscode # gui code editor

    # utility
    lazygit # git frontend
    nil # nix language server
    nixpkgs-fmt # code formater for nix
    neofetch # A fast, highly customizable system info script
    cmatrix # Simulates the falling characters theme from The Matrix movie
    usbimager # flash os iso images on usb drive

    # easyfatt
    nodejs # Event-driven I/O framework for the V8 JavaScript engine
    lftp # ftp client requisito easyfatt

    # neovim and lazyvim reqs (neovim distribution)
    neovim # terminal editor
    gcc # c compiler
    ripgrep # A utility that combines the usability of The Silver Searcher with the raw speed of grep
    fd # A simple, fast and user-friendly alternative to find
    wl-clipboard # Command-line copy/paste utilities for Wayland
    unrar # unfree utility for RAR archives
    unzip # An extraction utility for archives compressed in .zip format
  ];

  # editor
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # self enable
  programs.home-manager = {
    enable = true;
  };
}
