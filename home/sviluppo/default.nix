# nixos/home/sviluppo/default.nix

{ config, pkgs, ... }:

{
  # Import common configurations
  imports = [
    ../default.nix
    ../../modules/home/gnome-theme.nix
    ../../modules/home/bash.nix
  ];

  # username
  home.username = "sviluppo";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    upscayl
  ];

  # Any user-specific overrides or additional configurations can go here

  # State version should be kept in the user's config
  home.stateVersion = "23.11";
}
