{ pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "acquisti";
  home.homeDirectory = "/home/acquisti";

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
    # terminal
    ./usr-modules/alacritty.nix
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
    ungoogled-chromium # browser
    vscodium # gui code editor
    libreoffice-fresh # open source office suite
    thunderbird # mail client
    gimp # pixel design
    inkscape # vector design
    nodejs # Event-driven I/O framework for the V8 JavaScript engine
    lftp # ftp client requisito easyfatt
    neofetch # A fast, highly customizable system info script
    obsidian # Personal Knowledge Managment
    # logseq # Personal Knowledge Managment
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
