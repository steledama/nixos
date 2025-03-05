# nixos/modules/system/hardware/nvidia.nix

{ config
, pkgs
, ...
}: {
  # Disable the open source nouveau driver
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Load NVIDIA driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  nixpkgs.config.nvidia.acceptLicense = true;

  # Graphics and hardware support
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true; # For 32-bit applications
    };

    enableRedistributableFirmware = true;

    # NVIDIA specific configuration
    nvidia = {
      # Enable modesetting for Wayland compatibility
      modesetting.enable = true;

      # Enable NVIDIA settings utility
      nvidiaSettings = true;

      # Use the open kernel module for RTX/GTX 16xx or newer GPUs
      # Set to false for older GPUs
      open = true;

      # Use the stable driver package
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # Force full composition pipeline - enable if you see screen tearing
      forceFullCompositionPipeline = false;

      # Power management options
      powerManagement = {
        enable = false; # Enable for better suspend/resume with modern GPUs
        finegrained = false; # For Turing+ GPUs
      };
    };
  };

  # Add NVIDIA related packages
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia # GPU monitoring
    cudaPackages.cudatoolkit # CUDA development tools
  ];
}

