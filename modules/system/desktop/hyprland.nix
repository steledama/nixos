# modules/system/desktop/hyprland.nix
# System-level Hyprland configuration
{pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Specific Hyprland portal
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-hyprland];
  xdg.portal.config.hyprland.default = ["gtk" "hyprland"];
}
