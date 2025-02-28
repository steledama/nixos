{ config, lib, ... }:

{
  # Map CapsLock to Ctrl+a for tmux prefix
  services.udev.extraHwdb = ''
    evdev:input:b*v*p*e*-*
     KEYBOARD_KEY_3a=leftctrl+a
  '';
}
