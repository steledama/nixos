# nixos/modules/system/services/ollama.nix
{ pkgs, config, lib, ... }:

{
  # Configurazione base di Ollama
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  # Pacchetti CUDA necessari per il funzionamento
  environment.systemPackages = with pkgs; [
    # Toolkit CUDA principale
    cudaPackages.cudatoolkit

    # Librerie per il deep learning
    cudaPackages.cudnn

    # Runtime CUDA
    cudaPackages.cuda_cudart

    # Librerie per algebra lineare
    cudaPackages.libcublas

    # Altre librerie utili
    cudaPackages.libcufft
    cudaPackages.libcurand
    cudaPackages.libcusolver
  ];

  # Configurazione avanzata del servizio systemd
  systemd.services.ollama = {
    # Assicurati che il servizio abbia accesso ai dispositivi GPU
    serviceConfig = {
      # Aggiungi i gruppi necessari per accedere alla GPU
      SupplementaryGroups = [ "video" "render" ];

      # Variabili d'ambiente critiche per l'uso della GPU
      Environment = [
        "NVIDIA_VISIBLE_DEVICES=all"
        "CUDA_VISIBLE_DEVICES=0"
        "LD_LIBRARY_PATH=/run/opengl-driver/lib:${config.hardware.nvidia.package.outPath}/lib"
        "OLLAMA_CUDA=1"
        "OLLAMA_USE_CPU=0"
        "OLLAMA_HOST=127.0.0.1:11434"
        "OLLAMA_DEBUG=1"
      ];
    };

    # Assicurati che il servizio parta dopo che il dispositivo NVIDIA è disponibile
    requires = [ "dev-nvidia0.device" ];
    after = [
      "syslog.target"
      "network.target"
      "dev-nvidia0.device"
    ];
  };

  # Script di attivazione per creare i link simbolici necessari
  system.activationScripts.ollamaCudaLinks = {
    text = ''
      # Crea directory se non esistente
      mkdir -p /usr/lib/x86_64-linux-gnu
      
      # Link per libcuda
      ln -sf ${config.hardware.nvidia.package.outPath}/lib/libcuda.so.1 /usr/lib/x86_64-linux-gnu/libcuda.so.1
      ln -sf ${config.hardware.nvidia.package.outPath}/lib/libcuda.so /usr/lib/x86_64-linux-gnu/libcuda.so
      
      # Link per librerie CUDA runtime
      ln -sf ${pkgs.cudaPackages.cuda_cudart}/lib/libcudart.so /usr/lib/x86_64-linux-gnu/libcudart.so
      
      # Link per librerie cuBLAS
      ln -sf ${pkgs.cudaPackages.libcublas}/lib/libcublas.so /usr/lib/x86_64-linux-gnu/libcublas.so
      
      # Directory per log
      mkdir -p /var/log/ollama
      chmod 755 /var/log/ollama
    '';
    deps = [ ];
  };

  # Assicurati che i moduli del kernel NVIDIA siano caricati
  boot.kernelModules = [ "nvidia" "nvidia_uvm" "nvidia_drm" "nvidia_modeset" ];
}

