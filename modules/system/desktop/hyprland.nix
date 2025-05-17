# modules/system/desktop/hyprland.nix
# System-level Hyprland configuration
{...}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
