{ pkgs, config, ... }:

{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "it";
      variant = "";
    };
    # touchpad support
    libinput.enable = true;
    # display manager
    displayManager.sddm = {
      enable = true;
      # autoNumlock = true;
      wayland.enable = true;
    };
  };
}

