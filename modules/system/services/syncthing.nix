# nixos/modules/system/services/syncthing.nix
{config, lib, ...}:
with lib; {
  options.services.syncthingSystem = {
    enable = mkEnableOption "Syncthing system service";
    user = mkOption {
      type = types.str;
      default = "syncthing";
      description = "User to run Syncthing service as";
    };
    guiAddress = mkOption {
      type = types.str;
      default = "127.0.0.1:8384";
      description = "GUI listen address";
    };
  };

  config = mkIf config.services.syncthingSystem.enable {
    services.syncthing = {
      enable = true;
      user = "syncthing";
      group = "syncthing";
      dataDir = "/var/lib/syncthing";
      configDir = "/var/lib/syncthing/.config/syncthing";
      guiAddress = config.services.syncthingSystem.guiAddress;
    };

    # Create dedicated syncthing system user
    users.users.syncthing = {
      isSystemUser = true;
      group = "syncthing";
      home = "/var/lib/syncthing";
    };

    users.groups.syncthing = {};

    # Add the specified user to syncthing group for access
    users.users.${config.services.syncthingSystem.user}.extraGroups = mkIf (config.services.syncthingSystem.user != "syncthing") ["syncthing"];
  };
}