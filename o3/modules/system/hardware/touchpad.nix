{
  # Enable touchscreen and input support through libinput
  services.libinput = {
    enable = true;
    # Touchscreen configuration
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      disableWhileTyping = true;
    };
  };
}
