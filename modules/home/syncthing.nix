# nixos/modules/home/syncthing.nix
# to configure 127.0.0.1:8384
{
  services = {
    syncthing = {
      enable = true;
      # tray.enable = true; # tray
      # user = "acquisti"; # user
      # dataDir = "/home/acquisti"; # Default folder for new synced folders
      # configDir = "/home/acquisti/.config/syncthing"; # Folder for Syncthing's settings and keys
    };
  };
}
