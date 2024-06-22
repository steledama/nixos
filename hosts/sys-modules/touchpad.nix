{ pkgs, config, ... }:

{
  services.libinput = {
    # touchpad support
    enable = true;
    # tap
    touchpad.tapping = true;
    # display manager: gnome login
  };
}

