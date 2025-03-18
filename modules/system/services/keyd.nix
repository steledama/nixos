# modules/system/keyd.nix
{ ...
}: {

  # Configure keyd for CapsLock to Esc
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "escape";
          };
        };
      };
    };
  };
}

