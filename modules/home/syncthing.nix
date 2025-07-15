# nixos/modules/home/syncthing.nix
{
  services = {
    syncthing = {
      enable = true;
      # tray.enable = true; # tray
      # user = "acquisti"; # user
      # dataDir = "/home/acquisti"; # Default folder for new synced folders
      # configDir = "/home/acquisti/.config/syncthing"; # Folder for Syncthing's settings and keys
      settings = {
        gui = {
          address = "0.0.0.0:8384";
        };
      };
    };
  };
}
