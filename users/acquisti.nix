{ config, pkgs, ... }:

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
    firefox # personal browser
    gimp # pixel design
    inkscape # vector design
    libreoffice-fresh # open source office suite
    mailspring # posta
    # unfree software
    anydesk # remote dektop
    obsidian # writing and note taking tool
    vscode # gui code editor
    # utility
    lazygit # git frontend
    nixpkgs-fmt # code formater for nix
    neofetch # A fast, highly customizable system info script
    cmatrix # Simulates the falling characters theme from The Matrix movie
    usbimager # flash os iso images on usb drive
    # easyfatt
    nodejs # Event-driven I/O framework for the V8 JavaScript engine
    lftp # ftp client requisito easyfatt
    # neovim and lazyvim (neovim distribution)
    neovim # terminal editor
    gcc # c compiler
    ripgrep # A utility that combines the usability of The Silver Searcher with the raw speed of grep
    fd # A simple, fast and user-friendly alternative to find
    wl-clipboard # Command-line copy/paste utilities for Wayland
    unrar # unfree utility for RAR archives
    unzip # An extraction utility for archives compressed in .zip format

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # editor
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  # self enable
  programs.home-manager = {
    enable = true;
  };

  # browser with some fonts settings
  programs.google-chrome = {
    enable = true;
    package = pkgs.google-chrome;
    commandLineArgs = [
      "--enable-features=WebUIDarkMode"
      "--force-dark-mode"
      "--disable-features=UseChromeOSDirectVideoDecoder"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
    ];
  };
  # fonts settings for gnome
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      font-antialiasing = "rgba";
      font-hinting = "slight";
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/stefano/etc/profile.d/hm-session-vars.sh
}
