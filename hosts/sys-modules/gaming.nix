{ config, pkgs, ... }:

{
  # Abilita Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Apre le porte per Steam Remote Play
    dedicatedServer.openFirewall = true; # Apre le porte per i server dedicati Steam
  };

  # Installa Lutris, Heroic e Bottles
  environment.systemPackages = with pkgs; [
    lutris
    heroic
    bottles
    wineWowPackages.stable
    winetricks
    protontricks
    protonge  # Versione personalizzata di Proton
  ];

  # Abilita il supporto 32-bit (necessario per molti giochi)
  hardware.opengl.driSupport32Bit = true;

  # Ottimizzazioni per il gaming
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  # Abilita GameMode
  programs.gamemode.enable = true;

  # Abilita Feral GameMode
  environment.systemPackages = with pkgs; [
    gamemode
  ];
}