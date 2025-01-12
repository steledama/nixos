{ pkgs, config, ... }:

{
  # Disable nouveau
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Enable NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    forceFullCompositionPipeline = true;
  };

  # Essential NVIDIA packages
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia # Per monitorare la GPU
  ];
}
