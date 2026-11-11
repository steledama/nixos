# modules/home/shell.nix
# Central configuration for shell and terminal utilities
# This module contains tools that work with any shell (Fish, Zsh, Bash)
# Shell-specific configuration is in separate modules (fish.nix, zsh.nix, etc.)
{pkgs, ...}: {
  imports = [
    ./fish.nix # Current shell - switch to zsh.nix + starship.nix if needed
    ./herdr.nix # Agent multiplexer - multiplexer terminale principale
    ./yazi.nix # Terminal file manager
  ];

  # Default terminal emulator for apps that need to spawn a terminal
  home.sessionVariables.TERMINAL = "foot";

  # Shell and terminal utilities
  home.packages = with pkgs; [
    fastfetch # System info script
    jq # JSON processor CLI
  ];

  # fzf - Fuzzy finder with shell integration
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    # Key bindings: Ctrl+R (history), Ctrl+T (files), Alt+C (cd)
  };

  # zoxide - Smart cd command
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    # Usage: z <partial-name> (e.g., 'z nixos')
  };

  # direnv - Declarative config for nix-direnv integration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # Better Nix integration with persistent cache
  };
}
