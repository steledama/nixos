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
    btop # Resource monitor (desktop entry in niri.nix)
    wev # Wayland event viewer
    bc # Arbitrary precision calculator
    zip # Create and modify zip archives
    lftp # FTP/SFTP/FTPS client (desktop entry in niri.nix)
    ripgrep # Fast recursive grep
    tree # Directory tree viewer
    imagemagick # Image inspection and conversion (identify, magick)
    ffmpeg # Audio/video processing (ffmpeg, ffprobe)
    poppler-utils # PDF utilities (pdfinfo, pdftotext)
    qpdf # PDF transformation and inspection
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
