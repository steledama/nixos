# modules/system/hardware/keyboard.nix
# Centralized keyboard configuration module
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hardware.keyboard;
in {
  options.hardware.keyboard = {
    # Main keyboard layout
    layout = mkOption {
      type = types.str;
      default = "us";
      description = "Keyboard layout";
      example = "it";
    };

    # Layout variant (if applicable)
    variant = mkOption {
      type = types.str;
      default = "intl";
      description = "Keyboard variant";
      example = "dvorak";
    };

    # Additional keyboard options
    options = mkOption {
      type = types.str;
      default = "compose:ralt";
      description = "Keyboard options";
      example = "caps:escape";
    };
  };

  config = {
    # TTY console configuration
    console.keyMap = cfg.layout;

    # X11/Wayland configuration
    services.xserver.xkb = {
      layout = cfg.layout;
      variant = cfg.variant;
      options = cfg.options;
    };
  };
}
