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
    # unfree software
    firefox # personal browser
    brave # work browser
    obsidian # writing and note taking tool
    # vscode # gui code editor

    # FOSS
    ungoogled-chromium # FOSS chrome
    zettlr # FOSS writing and note taking tool
    vscodium # vscode FOSS

    # office
    libreoffice-fresh # open source office suite
    evolution # mail client

    # graphics
    gimp # pixel design
    inkscape # vector design

    # easyfatt
    nodejs # Event-driven I/O framework for the V8 JavaScript engine
    lftp # ftp client requisito easyfatt

    # utility
    neofetch # A fast, highly customizable system info script
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
