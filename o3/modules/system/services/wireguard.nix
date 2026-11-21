{
  config,
  lib,
  ...
}: let
  cfg = config.services.wireguardServer;

  listenPort = 51820;
  allowedSourceSubnets = [cfg.vpnSubnet] ++ cfg.lanSubnets;

  protectRuleLines =
    lib.concatMapStrings (
      port:
        lib.concatMapStrings
        (subnet: ''
          iptables -A nixos-fw -s ${subnet} -p tcp --dport ${toString port} -j nixos-fw-accept
        '')
        allowedSourceSubnets
    )
    cfg.protectedTcpPorts;
in {
  options.services.wireguardServer = {
    enable = lib.mkEnableOption "WireGuard VPN server";

    interfaceName = lib.mkOption {
      type = lib.types.str;
      example = "casa";
      description = ''
        WireGuard interface name for this server: a runtime name the operator
        types (`casa` on deck), so it is set by the host and has no default.
      '';
    };

    vpnSubnet = lib.mkOption {
      type = lib.types.str;
      example = "10.20.0.1/24";
      description = "WireGuard server address and subnet assigned to the interface.";
    };

    externalInterface = lib.mkOption {
      type = lib.types.str;
      description = "External network interface facing the internet.";
    };

    privateKeyFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to the WireGuard private key file.";
    };

    peers = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          publicKey = lib.mkOption {
            type = lib.types.str;
            description = "WireGuard public key for the peer.";
          };

          allowedIPs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "IP addresses assigned to the peer inside the VPN.";
          };
        };
      });
      default = [];
      description = "WireGuard peers allowed to connect to the server.";
    };

    lanSubnets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "LAN subnets reachable through the VPN.";
    };

    protectedTcpPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [];
      description = "TCP ports exposed only to VPN and LAN clients.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
    };

    networking.wireguard.interfaces.${cfg.interfaceName} = {
      ips = [cfg.vpnSubnet];
      inherit listenPort;
      privateKeyFile = cfg.privateKeyFile;
      peers =
        map (peer: {
          inherit (peer) publicKey allowedIPs;
        })
        cfg.peers;
    };

    networking.nat = {
      enable = true;
      externalInterface = cfg.externalInterface;
      internalInterfaces = [cfg.interfaceName];
    };

    networking.firewall.allowedUDPPorts = [listenPort];

    networking.firewall.extraCommands = lib.mkAfter protectRuleLines;
  };
}
