# modules/system/desktop/niri.nix
{pkgs, ...}: {
  programs.niri = {
    enable = true;
    package = pkgs.niri-stable;
  };

  # Register with display manager
  services.displayManager.sessionPackages = [pkgs.niri-stable];
}
