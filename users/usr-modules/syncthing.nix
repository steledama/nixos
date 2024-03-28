{ pkgs, config, ... }:
{

  # syncthing
  services = {
    syncthing = {
      enable = true;
      tray.enable = true;
      # user = "ttacquisti";
      # dataDir = "/home/ttacquisti"; # Default folder for new synced folders
      # configDir = "/home/ttacquisti/.config/syncthing"; # Folder for Syncthing's settings and keys
    };
  };
}
