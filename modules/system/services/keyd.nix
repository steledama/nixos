# nixos/modules/services/keyd

{
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "macro(ctrl+b)";
          };
        };
      };
    };
  };
}
