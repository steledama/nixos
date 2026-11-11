# modules/system/hardware/nvidia.nix
# NVIDIA GPU driver configuration for RTX 40-series (Ada Lovelace)
{
  config,
  pkgs,
  ...
}: {
  # Disable the open source nouveau driver
  boot.blacklistedKernelModules = ["nouveau"];

  # Load NVIDIA driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  # Accept NVIDIA license (required for proprietary packages)
  nixpkgs.config.nvidia.acceptLicense = true;

  # UNFREE: driver NVIDIA proprietari e toolkit CUDA
  unfree.allowedNames = [
    # NVIDIA drivers and tools
    "nvidia-x11"
    "nvidia-settings"
    "nvidia-persistenced"
    # CUDA toolkit
    "cccl" # ex cuda_cccl, rinominato upstream (nixpkgs fe13242)
    "cuda_crt" # separato da cuda_nvcc upstream (nixpkgs fe13242)
    "libnvvm" # separato da cuda_nvcc upstream (nixpkgs fe13242)
    "cuda_cudart"
    "cuda_cuobjdump"
    "cuda_cupti"
    "cuda_cuxxfilt"
    "cuda_gdb"
    "cuda_nvcc"
    "cuda_nvdisasm"
    "cuda_nvml_dev"
    "cuda_nvprune"
    "cuda_nvrtc"
    "cuda_nvtx"
    "cuda_profiler_api"
    "cuda_sanitizer_api"
    "cuda-merged"
    "cudatoolkit"
    "libcublas"
    "libcufft"
    "libcurand"
    "libcusolver"
    "libcusparse"
    "libnpp"
    "libnvjitlink"
  ];

  # Graphics and hardware support
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true; # For 32-bit applications (Wine, Steam)
    };

    enableRedistributableFirmware = true;

    # NVIDIA specific configuration
    nvidia = {
      # Enable modesetting for Wayland compatibility
      modesetting.enable = true;

      # Enable NVIDIA settings utility
      nvidiaSettings = true;

      # Use the open kernel module for RTX 30/40 series GPUs
      # Ada Lovelace (RTX 40xx) fully supports open modules
      open = true;

      # Use the stable driver package
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # Force full composition pipeline - enable if you see screen tearing
      forceFullCompositionPipeline = false;

      # Power management: save/restore GPU state on suspend/resume
      # Required to avoid "Flip event timeout" errors after waking from sleep
      powerManagement = {
        enable = true;
        finegrained = false;
      };
    };
  };

  # CUDA support globale — abilitato a livello hardware, non per singolo servizio.
  # game ha una sola RTX 4070 (Ada, compute capability 8.9): limitare i target
  # evita che i pacchetti locali compilino kernel per tutte le famiglie NVIDIA.
  nixpkgs.config = {
    cudaSupport = true;
    cudaCapabilities = ["8.9"];
  };

  # NVIDIA-related packages
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia # GPU monitoring
  ];
}
