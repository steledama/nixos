{ config, pkgs, ... }:
{
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
  };

  # (Opzionale) Pacchetto per il monitoraggio della GPU
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
