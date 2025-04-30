# home/stefano/default.nix
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../default.nix
    ../../modules/home/wm.nix
  ];

  # username
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";

  # Setup keyboard configuration for Wayland WMs 
  # e attivazione di entrambi i window manager
  wayland-wm = {
    enable = true;
    enableHyprland = true; # Abilita Hyprland
    enableNiri = true;     # Abilita Niri
    keyboard = {
      layout = "it";
      variant = "";
      options = "";
    };
  };

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    amule
  ];

  home.stateVersion = "23.11";
}
