# modules/system/services/gdm.nix
{
  # X server
  services.xserver = {
    enable = true;

    # Keyboard
    xkb = {
      layout = "it";
      variant = "";
      options = "";
    };

    # Display manager GDM
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  console.keyMap = "it";
}
