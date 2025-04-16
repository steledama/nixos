# modules/system/hardware/minibook.nix
# Specific hardware configuration for Chuwi MiniBook X
{ config, lib, pkgs, ... }:

{
  # Fix for screen orientation
  boot.kernelParams = [ "video=DSI-1:panel_orientation=right_side_up" ];

  # Enable fractional scaling for the high resolution display
  # GNOME settings
  environment.sessionVariables = {
    # Force the proper driver for Intel graphics for better performance
    MESA_LOADER_DRIVER_OVERRIDE = "iris";
  };

  # Enable touchscreen support
  hardware.touchscreen.enable = true;

  # Add specific packages useful for the MiniBook
  environment.systemPackages = with pkgs; [
    # For screen rotation based on accelerometer
    iio-sensor-proxy
    
    # For battery management
    powertop
    tlp
  ];

  # Install GNOME extension for screen rotation (since tablet mode switch doesn't work yet)
  # Note: This would need to be in the home-manager configuration
  # home.packages = with pkgs; [
  #   gnomeExtensions.screen-rotate
  # ];

  # Better power management for Intel hardware
  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    };
  };

  # Additional hardware configuration
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Notes:
  # - The tablet mode switch is not currently supported in Linux
  # - The accelerometer works since Linux 6.9.0 but requires additional configuration for auto-rotation
  # - The display may have issues between Linux 6.6.15 and 6.9.0
}
