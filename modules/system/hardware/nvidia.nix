{ config
, pkgs
, ...
}: {
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  hardware.nvidia = {
    # Modesetting is prequired
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Enable the Nvidia settings menu accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # GPU with Turing architecture (RTX 20-Series) or newer it is recommended by NVIDIA to use the open Drivers
    open = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.latest; # stable, latest, beta, production
  };

  # (Opzionale) Pacchetto per il monitoraggio della GPU
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    cudaPackages.cudatoolkit
    cudaPackages.nvidia_driver
    cudaPackages.tensorrt
  ];

}
