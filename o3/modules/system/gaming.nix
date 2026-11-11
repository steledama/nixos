# modules/system/gaming.nix
# Gaming packages and optimizations for Linux gaming
{
  lib,
  pkgs,
  ...
}:
with lib; {
  # UNFREE: Steam (client proprietario Valve)
  unfree.allowedNames = [
    "steam"
    "steam-original"
    "steam-run"
    "steam-unwrapped"
  ];

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    # Enable Proton-GE and other compatibility tools
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # Gaming tools (minimal set - add more as needed)
  environment.systemPackages = with pkgs; [
    heroic # Epic Games, GOG and Amazon Games launcher
    mangohud # Performance overlay (FPS, temps, etc.)
  ];

  # Enable 32-bit support (necessary for many games)
  hardware.graphics.enable32Bit = true;

  # Gaming kernel optimizations
  boot.kernel.sysctl = {
    # Reduce swap usage for better gaming performance
    "vm.swappiness" = 10;
    # Keep filesystem metadata in cache longer
    "vm.vfs_cache_pressure" = 50;
  };

  # Enable GameMode service
  programs.gamemode = {
    enable = true;
    enableRenice = true; # Allow GameMode to renice processes
  };
}
