# modules/system/services/gdm.nix
{
  # X server
  services = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
}
