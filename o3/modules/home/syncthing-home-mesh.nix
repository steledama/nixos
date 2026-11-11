# modules/home/syncthing-home-mesh.nix
#
# Syncthing mesh shared by the three home clients (neve, game, deck).
# Single source of truth for device IDs and LAN addresses: each host imports
# this module and declares its own name; peers are derived by exclusion.
{
  config,
  lib,
  identity,
  ...
}: let
  cfg = config.services.syncthingHomeMesh;

  # Registry of mesh members, derived from identity/home.nix: device IDs (public
  # keys) and LAN IPs are identifying data kept out of the structural config.
  # Adding a host there propagates to every peer.
  meshDevices =
    lib.mapAttrs (name: id: {
      inherit id;
      addresses = ["tcp://${identity.home.lan.hosts.${name}}:22000"];
    })
    identity.home.syncthing.deviceIds;

  peerNames = lib.filter (n: n != cfg.thisHost) (lib.attrNames meshDevices);
  peerDevices = lib.filterAttrs (n: _: n != cfg.thisHost) meshDevices;
in {
  options.services.syncthingHomeMesh = {
    enable = lib.mkEnableOption "home mesh Syncthing configuration";

    thisHost = lib.mkOption {
      type = lib.types.enum (lib.attrNames meshDevices);
      description = "Name of the current host in the mesh registry.";
    };

    syncPath = lib.mkOption {
      type = lib.types.str;
      description = "Absolute path to the synced folder for this user.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:8384";

      settings = {
        devices = peerDevices;
        folders.sync = {
          path = cfg.syncPath;
          devices = peerNames;
          type = "sendreceive";
          fsWatcherEnabled = true;
        };
        options.urAccepted = -1;
      };
    };
  };
}
