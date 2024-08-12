# This module provides configuration options for static and bridge network setups

{ config, lib }:

with lib;

let
  cfg = config.networking.customSetup;
in
{
  options.networking.customSetup = {
    type = mkOption {
      type = types.enum [ "static" "bridge" ];
      description = "Type of network configuration (static or bridge)";
    };

    staticIP = mkOption {
      type = types.submodule {
        options = {
          address = mkOption {
            type = types.str;
            example = "192.168.1.100";
            description = "Static IP address to assign to the interface";
          };
          prefixLength = mkOption {
            type = types.int;
            default = 24;
            description = "Network prefix length for the static IP (default: 24)";
          };
        };
      };
      description = "Static IP configuration (used for both static and bridge types)";
    };

    gateway = mkOption {
      type = types.str;
      example = "192.168.1.1";
      description = "IP address of the default gateway";
    };

    nameservers = mkOption {
      type = types.listOf types.str;
      default = [ "8.8.8.8" "8.8.4.4" ];
      example = [ "192.168.1.1" "8.8.8.8" ];
      description = "List of IP addresses of DNS servers";
    };

    bridgeConfig = mkOption {
      type = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            default = "br0";
            description = "Name of the bridge interface";
          };
        };
      };
      default = { };
      description = "Bridge configuration (only used when type is 'bridge')";
    };

    interface = mkOption {
      type = types.str;
      default = "";
      description = "The name of the network interface (usually auto-detected)";
    };
  };

  config = mkMerge [
    {
      networking = {
        useDHCP = false;
        networkmanager.enable = false;
        defaultGateway = cfg.gateway;
        nameservers = cfg.nameservers;
      };
    }
    (mkIf (cfg.type == "static" || cfg.type == "bridge") {
      networking.interfaces =
        if (cfg.interface != "") then {
          ${cfg.interface} = {
            useDHCP = false;
            ipv4.addresses = [{
              address = cfg.staticIP.address;
              prefixLength = cfg.staticIP.prefixLength;
            }];
          };
        } else { };
    })
    (mkIf (cfg.type == "bridge") {
      networking.bridges = {
        ${cfg.bridgeConfig.name} = {
          interfaces = optional (cfg.interface != "") cfg.interface;
        };
      };
    })
  ];
}
