{ pkgs, ... }:

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
    firefox # private browser
    google-chrome # work browser
    libreoffice-fresh # open source office suite
    thunderbird # mail client
    gimp # pixel design
    inkscape # vector design
    obsidian # Personal Knowledge Managment
    vscode # gui code editor
    amule # Peer-to-peer client for the eD2K and Kademlia networks
    filezilla # ftp client
    alacritty # terminal emulator
    neofetch # A fast, highly customizable system info script
    starship
    syncthing
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
