# nixos/home/acquisti/default.nix
{
  config,
  pkgs,
  neovim-config,
  ...
}: {
  imports = [
    ../default.nix
    ../../modules/home/syncthing.nix
  ];
  # username
  home.username = "acquisti";
  home.homeDirectory = "/home/${config.home.username}";

  # keyboard settings (for hyprland)
  custom.keyboard = {
    layout = "no";
    variant = "";
    options = "compose:ralt";
  };

  # User-specific packages (additional to common ones)
  home.packages = with pkgs; [
    anydesk # Remote desktop software
    insomnia # API client
  ];

  home.stateVersion = "23.11";
}
