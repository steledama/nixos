{
  config,
  lib,
  ...
}: let
  cfg = config.services.wireguardWorkClient;
  # Explicit peer name → predictable systemd unit name. Without it nixpkgs
  # derives the name from the public key, escaping +/= to \x2b/\x3d, which is
  # awkward to target for the self-heal override below.
  peerName = "office";
  peerUnit = "wireguard-${cfg.interfaceName}-peer-${peerName}";
in {
  options.services.wireguardWorkClient = {
    enable = lib.mkEnableOption "WireGuard client for the office VPN";

    interfaceName = lib.mkOption {
      type = lib.types.str;
      default = "lavoro";
      description = "WireGuard interface name used for the office VPN client.";
    };

    address = lib.mkOption {
      type = lib.types.str;
      example = "10.0.1.10/32";
      description = "VPN address assigned to this client.";
    };

    privateKeyFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to the client private key kept outside git.";
    };

    serverPublicKey = lib.mkOption {
      type = lib.types.str;
      description = "WireGuard public key exposed by the office VPN server.";
    };

    endpoint = lib.mkOption {
      type = lib.types.str;
      example = "vpn.example.com:51820";
      description = "Public endpoint of the office VPN server.";
    };

    allowedIPs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      example = ["10.0.1.0/24" "10.0.0.0/24"];
      description = "Networks routed through the office VPN.";
    };

    hosts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {server = "10.0.0.10";};
      description = ''
        Office LAN names resolved in /etc/hosts on this host, the only one
        that reaches the office LAN (through this VPN).
      '';
    };

    persistentKeepalive = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = 25;
      description = "Keepalive interval for NAT traversal.";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start the WireGuard interface automatically at boot. Set false for on-demand use.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure DNS is available before resolving the VPN endpoint hostname
    systemd.services."wireguard-${cfg.interfaceName}" = {
      wants = ["nss-lookup.target"];
      after = ["nss-lookup.target"];
    };

    # Self-heal the peer unit. The endpoint hostname is resolved inside this
    # unit's ExecStart (`wg set ... endpoint ...`), so a transient DNS failure
    # leaves the interface up but without a peer (no route to the office LAN).
    # Retry until resolution succeeds instead of staying half-started.
    systemd.services.${peerUnit} = {
      wants = ["nss-lookup.target"];
      after = ["nss-lookup.target"];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "10s";
      };
      # Never give up: keep retrying if DNS stays down past the default burst.
      startLimitIntervalSec = 0;
    };

    networking.wireguard.interfaces.${cfg.interfaceName} = {
      ips = [cfg.address];
      privateKeyFile = cfg.privateKeyFile;
      peers = [
        {
          name = peerName;
          publicKey = cfg.serverPublicKey;
          endpoint = cfg.endpoint;
          allowedIPs = cfg.allowedIPs;
          persistentKeepalive = cfg.persistentKeepalive;
        }
      ];
    };

    networking.hosts = lib.mapAttrs' (name: address: lib.nameValuePair address [name]) cfg.hosts;

    systemd.targets."wireguard-${cfg.interfaceName}" = lib.mkIf (!cfg.autoStart) {
      wantedBy = lib.mkForce [];
    };
  };
}
