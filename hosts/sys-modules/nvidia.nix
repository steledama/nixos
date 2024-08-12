{ pkgs, config, ... }:

{
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    forceFullCompositionPipeline = true;
  };

  environment.sessionVariables = {
    ELECTRON_ENABLE_LOGGING = "1";
    ELECTRON_FORCE_WINDOW_MENU_BAR = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NVIDIA_FORCE_MAX_CLOCKS = "1";
    # Force nvidia for electron app
    ELECTRON_OVERRIDE_DIST_PATH = "${pkgs.electron}/lib/electron";
  };
}


