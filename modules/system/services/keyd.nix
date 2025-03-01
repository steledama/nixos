# nixos/modules/services/keyd
{
  config,
  lib,
  pkgs,
  ...
}: {
  # CapsLock to Ctrl+b remap
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            capslock = "C-b";
          };
        };
      };
    };
  };
}
