{ pkgs, ... }:

{
  # Import common configurations
  imports = [
    ../default.nix
    ../../modules/home/syncthing.nix
    ../../modules/home/gnome-theme.nix
  ];

  # User-specific information
  home.username = "acquisti";
  home.homeDirectory = "/home/acquisti";

  # State version should be kept in the user's config
  home.stateVersion = "23.11";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    anydesk # Remote desktop software
    insomnia # API client
  ];

  # Any user-specific overrides or additional configurations can go here
}
