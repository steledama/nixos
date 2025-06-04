# modules/system/services/gdm.nix
{
  # X server
  services = {
    xserver.enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
}
