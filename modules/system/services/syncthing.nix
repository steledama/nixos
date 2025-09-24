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
      user = config.services.syncthingSystem.user;
      group = config.services.syncthingSystem.user;
      dataDir = "/var/lib/syncthing";
      configDir = "/var/lib/syncthing/.config/syncthing";
      guiAddress = config.services.syncthingSystem.guiAddress;
    };

    # Ensure the user exists
    users.users.${config.services.syncthingSystem.user} = mkIf (config.services.syncthingSystem.user != "root") {
      isSystemUser = true;
      group = config.services.syncthingSystem.user;
      home = "/var/lib/syncthing";
    };

    users.groups.${config.services.syncthingSystem.user} = mkIf (config.services.syncthingSystem.user != "root") {};
  };
}