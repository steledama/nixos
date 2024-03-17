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
    displayManager.gdm = {
      enable = true;
      # autoNumlock = true;
    };
  };
}

