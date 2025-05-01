# modules/system/desktop/niri.nix
# System-level Niri configuration
{pkgs, ...}: {
  # Niri a livello di sistema
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };

  # XDG portal configuration for Niri
  xdg.portal.config.niri.default = ["gtk" "wlr"];

  # Register with display manager
  services.displayManager.sessionPackages = [pkgs.niri-unstable];
}
