# modules/home/keyboard-config.nix
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.keyboard;
in {
  options.custom.keyboard = {
    layout = mkOption {
      type = types.str;
      default = "us";
      description = "Keyboard layout";
    };

    variant = mkOption {
      type = types.str;
      default = "intl";
      description = "Keyboard variant";
    };

    options = mkOption {
      type = types.str;
      default = "compose:ralt";
      description = "Keyboard options";
    };
  };

  config = {
    # Applica la configurazione a Hyprland
    wayland.windowManager.hyprland.settings.input = {
      kb_layout = cfg.layout;
      kb_variant = cfg.variant;
      kb_options = cfg.options;
    };
  };
}
