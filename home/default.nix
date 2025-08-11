# nixos/home/default.nix
{
  # pkgs,
  inputs,
  ...
}: {
  # Import common home modules (server-oriented)
  # IMPORTANT: Only add terminal-based tools here!
  # GUI applications should go in modules/home/desktop-apps.nix
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../modules/home/shell-config.nix
    ../modules/home/neovim.nix
    ../modules/home/yazi.nix
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
