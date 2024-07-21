{ pkgs, config, ... }:

{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "it";
      variant = "";
    };
    # display manager: gnome login
    displayManager.gdm = {
      enable = true;
      wayland = false;
      # autoNumlock = true;
    };
  };
}

