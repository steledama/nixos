{ pkgs, config, ... }:
{
  # Enable networking
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # vm
  networking.useDHCP = false;
  networking.bridges = {
    "br0" = {
      interfaces = [ "enp7s0" ];
    };
  };
  networking.interfaces.br0.ipv4.addresses = [{
    address = "192.168.1.27";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.1" "8.8.8.8" ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
}

