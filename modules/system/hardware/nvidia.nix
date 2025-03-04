{ config
, pkgs
, ...
}: {
  # Disabilita il driver open source "nouveau"
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Abilita Xorg e imposta il driver Nvidia
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  # Configurazione Nvidia
  hardware.nvidia = {
    # Abilita il modesetting (passa nvidia-drm.modeset=1 al kernel)
    modesetting.enable = true;
    # Abilita nvidia-settings per verifiche e configurazioni grafiche
    nvidiaSettings = true;
    # Utilizza il pacchetto stabile dei driver Nvidia compatibile con il kernel in uso
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # Impostato su false per evitare un carico aggiuntivo; abilitalo se noti tearing
    forceFullCompositionPipeline = false;

    # NUOVA CONFIGURAZIONE RICHIESTA
    # Imposta su true per GPU Turing o successive (RTX series, GTX 16xx)
    # Imposta su false per GPU più vecchie
    open = true; # Cambia a false se hai una GPU più vecchia di RTX/GTX 16xx
  };

  # (Opzionale) Pacchetto per il monitoraggio della GPU
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    cudaPackages.cudatoolkit
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Utile per applicazioni a 32 bit
  };
}
