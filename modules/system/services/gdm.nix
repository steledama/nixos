# modules/system/services/gdm.nix
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
