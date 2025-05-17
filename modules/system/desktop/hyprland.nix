# modules/system/desktop/hyprland.nix
{...}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
