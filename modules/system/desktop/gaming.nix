{pkgs, ...}: {
  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Opens ports for Steam Remote Play
    dedicatedServer.openFirewall = true; # Opens ports for Steam dedicated servers
  };

  # Install Lutris, Heroic, Bottles and other gaming tools
  environment.systemPackages = with pkgs; [
    lutris
    heroic
    winetricks
    protontricks
    protonup-qt # for managing protonGE versions
    gamemode # Feral GameMode
    wine
  ];

  # Enable 32-bit support (necessary for many games)
  hardware.graphics.enable32Bit = true;

  # Gaming optimizations
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  # Enable GameMode
  programs.gamemode.enable = true;
}
