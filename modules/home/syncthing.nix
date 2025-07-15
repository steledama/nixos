# nixos/modules/home/syncthing.nix
{
  services = {
    syncthing = {
      enable = true;
      guiAddress = "0.0.0.0:8384";
    };
  };
}
