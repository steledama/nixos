# modules/system/hardware/minibook.nix
# Specific hardware configuration for Chuwi MiniBook X
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Fix for screen orientation
  boot.kernelParams = ["video=DSI-1:panel_orientation=right_side_up"];

  # Enable fractional scaling for the high resolution display
  # GNOME settings
  environment.sessionVariables = {
    # Force the proper driver for Intel graphics for better performance
    MESA_LOADER_DRIVER_OVERRIDE = "iris";
  };

  # Add specific packages useful for the MiniBook
  environment.systemPackages = with pkgs; [
    # For screen rotation based on accelerometer
    iio-sensor-proxy

    # For battery management
    powertop
  ];

  # Better power management for Intel hardware
  services.thermald.enable = true;

  # Power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  # Disable power-profiles-daemon to avoid conflicts with auto-cpufreq
  services.power-profiles-daemon.enable = false;

  # Enable CPU frequency scaling
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # Additional hardware configuration
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Notes:
  # - The tablet mode switch is not currently supported in Linux
  # - The accelerometer works since Linux 6.9.0 but requires additional configuration for auto-rotation
  # - The display may have issues between Linux 6.6.15 and 6.9.0
}
