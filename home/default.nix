# nixos/home/default.nix
{
  # pkgs,
  inputs,
  ...
}: {
  # Import common home modules (server-oriented)
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../modules/home/shell-config.nix
    ../modules/home/neovim.nix
    ../modules/home/yazi.nix
    ../modules/home/zed.nix
  ];

  # Common packages for all users (terminal-based)
  # home.packages = with pkgs; [
  # Essential terminal tools only
  # GUI apps moved to desktop-specific configs
  # ];

  # Common editor configuration
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Enable home-manager itself
  programs.home-manager = {
    enable = true;
  };
}
