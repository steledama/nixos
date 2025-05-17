# modules/system/desktop/niri.nix
# System-level Niri configuration
{pkgs, ...}: {
  # Niri a livello di sistema
  programs.niri = {
    enable = true;
    package = pkgs.niri-stable;
  };

  # Register with display manager
  services.displayManager.sessionPackages = [pkgs.niri-stable];
}
