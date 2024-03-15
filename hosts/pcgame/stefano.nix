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

# Imports program configuration
imports = [
 # alacritty
 ../../modules/home-manager/alacritty.nix
 ../../modules/home-manager/neofetch.nix
 ../../modules/home-manager/starship.nix
 ../../modules/home-manager/bash.nix
];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    inkscape # vector grphics
    zathura # pdf viewer
    # lazyvim (neovim distribution)
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) # font alacritty
    lazygit # git easyer
    gcc # c compiler
    nodejs # Event-driven I/O framework for the V8 JavaScript engine
    ripgrep # A utility that combines the usability of The Silver Searcher with the raw speed of grep
    fd # A simple, fast and user-friendly alternative to find
    unzip # An extraction utility for archives compressed in .zip format
    cmatrix # Simulates the falling characters theme from The Matrix movie
    neofetch # A fast, highly customizable system info script
    font-awesome # Font Awesome - OTF font

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  #home.file = {
  # # Building this configuration will create a copy of 'dotfiles/screenrc' in
  # # the Nix store. Activating the configuration will then make '~/.screenrc' a
  # # symlink to the Nix store copy.
  # ".screenrc".source = dotfiles/screenrc;

  # # You can also set the file content immediately.
  # ".gradle/gradle.properties".text = ''
  #   org.gradle.console=verbose
  #   org.gradle.daemon.idletimeout=3600000
  # '';
  # };

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
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager = {
    enable = true;
  };
}
