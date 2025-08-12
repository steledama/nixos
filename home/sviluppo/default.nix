# nixos/home/sviluppo/default.nix
{config, ...}: {
  imports = [
    ../default.nix
    ../../modules/home/syncthing.nix
    ../../modules/home/desktop-apps.nix
    ../../modules/home/dev-tools.nix
  ];
  # username
  home.username = "sviluppo";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages
  # home.packages = with pkgs; [
  #   packagename
  # ];

  home.stateVersion = "23.11";
}
