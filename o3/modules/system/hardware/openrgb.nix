# modules/system/hardware/openrgb.nix
# RGB lighting control for RAM, GPU, motherboard, etc.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hardware.openrgbControl;
in {
  options.hardware.openrgbControl = {
    enable = mkEnableOption "OpenRGB for RGB lighting control";
  };

  config = mkIf cfg.enable {
    # OpenRGB service with udev rules
    services.hardware.openrgb = {
      enable = true;
      # Run server on startup for persistent control
      # motherboard = "amd"; # Set automatically based on CPU
    };

    # i2c access for RAM RGB control
    hardware.i2c.enable = true;

    # OpenRGB GUI application
    environment.systemPackages = with pkgs; [
      openrgb-with-all-plugins
    ];
  };
}
