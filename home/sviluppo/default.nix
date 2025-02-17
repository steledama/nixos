{ pkgs, ... }:

{
  # Import common configurations
  imports = [
    ../default.nix
    ../../modules/home/syncthing.nix
  ];

  # User-specific information
  home.username = "sviluppo";
  home.homeDirectory = "/home/sviluppo";

  # State version should be kept in the user's config
  home.stateVersion = "23.11";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    upscayl
    # User-specific packages (additional to common ones)
  ];

  # Any user-specific overrides or additional configurations can go here
}
