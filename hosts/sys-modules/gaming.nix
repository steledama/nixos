{ pkgs }:

{
  # Configura Wine
  nixpkgs.config.wine.build = "wineWow";

  # Abilita Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Apre le porte per Steam Remote Play
    dedicatedServer.openFirewall = true; # Apre le porte per i server dedicati Steam
  };

  # Installa Lutris, Heroic, Bottles e altri strumenti per il gaming
  environment.systemPackages = with pkgs; [
    lutris
    heroic
    bottles
    wineWowPackages.stable
    winetricks
    protontricks
    protonup-qt # per gestire le versioni di protonGE
    gamemode # Feral GameMode
    wine
  ];

  # Abilita il supporto 32-bit (necessario per molti giochi)
  hardware.graphics.enable32Bit = true;

  # Ottimizzazioni per il gaming
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  # Abilita GameMode
  programs.gamemode.enable = true;

  # Configura Wine
  environment.sessionVariables = {
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";
  };
}
