# modules/system/common.nix
# Configurazioni comuni applicate a tutti gli host.
{
  config,
  lib,
  pkgs,
  inputs,
  ... 
}:

{
  # Abilita i pacchetti non-free (es. driver Nvidia)
  nixpkgs.config.allowUnfree = true;

  # Configurazione di base per home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    # Passa gli input del flake (es. nixvim) ai moduli di home-manager
    extraSpecialArgs = { inherit inputs; };
  };
}
