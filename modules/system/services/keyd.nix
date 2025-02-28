# nixos/modules/services/keyd
{ config, lib, pkgs, ... }:

{
  # Configurazione keyd per rimappare CapsLock a Ctrl+b
    services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "C-b";
          };
        };
      };
    };
  };
}


