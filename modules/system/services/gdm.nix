# modules/system/services/gdm.nix
# This file configures the GDM display manager
{
  # X server
  services.xserver = {
    enable = true;

    # GDM display manager
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
}
