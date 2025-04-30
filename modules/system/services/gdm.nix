# modules/system/services/gdm.nix
# Questo file configura il display manager GDM
{
  # X server
  services.xserver = {
    enable = true;

    # Display manager GDM
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
}
