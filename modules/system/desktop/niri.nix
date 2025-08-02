# modules/system/desktop/niri.nix
{pkgs, ...}: {
  programs.niri = {
    enable = true;
    package = pkgs.niri;  # Usa il pacchetto ufficiale nixpkgs
  };

  # Register with display manager
  services.displayManager.sessionPackages = [pkgs.niri];
}
