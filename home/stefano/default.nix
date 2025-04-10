# nixos/home/stefano/default.nix
{
  config,
  pkgs,
  neovim-config,
  ...
}: {
  imports = [
    ../default.nix
  ];

  # username
  home.username = "stefano";
  home.homeDirectory = "/home/${config.home.username}";

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    amule
  ];

  # keyboard settings (for hyprland)
  custom.keyboard = {
    layout = "it";
    variant = "";
    options = "";
  };

  home.stateVersion = "23.11";
}
