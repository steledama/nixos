# modules/system/hardware/deck.nix
# Specific hardware configuration for Chuwi MiniBook X
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Fix for screen orientation
  boot.kernelParams = [
    "video=DSI-1:panel_orientation=right_side_up"
    "fbcon=rotate:1" # Rotate framebuffer console 90° to match display orientation
  ];

  # Intel Graphics optimization
  environment.sessionVariables = {
    # Force modern Iris driver for Intel Gen 8+ GPUs (better performance than legacy i965)
    # Used by Mesa (OpenGL/Vulkan) across all desktop environments including COSMIC
    MESA_LOADER_DRIVER_OVERRIDE = "iris";
  };

  # Add specific packages useful for the MiniBook
  environment.systemPackages = with pkgs; [
    # For screen rotation based on accelerometer
    iio-sensor-proxy
  ];

  # Better power management for Intel hardware
  services.thermald.enable = true;

  # Additional hardware configuration
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Notes:
  # - The tablet mode switch is not currently supported in Linux
  # - The accelerometer works since Linux 6.9.0 but requires additional configuration for auto-rotation
  # - The display may have issues between Linux 6.6.15 and 6.9.0
  # - The Goodix touchscreen is detected by the kernel, but MangoWM currently appears
  #   not to handle touch events, so udev-side calibration alone is not sufficient
}
