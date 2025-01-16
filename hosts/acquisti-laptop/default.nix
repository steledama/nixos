# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ pkgs, inputs, ... }:

{
  imports = [
    # Import common configurations
    ../default.nix

    # Import hardware configuration
    ./hardware.nix

    # KERNEL (zen kernel specific to this host)
    ../../modules/system/zen.nix

    # GPU (specific to this host - intel)
    ../../modules/system/hardware/intel.nix

    # Docker (specific to this host)
    ../../modules/system/services/docker.nix

    # SMB (specific to this host)
    ../../modules/system/services/smb.nix

    # Touchpad (laptop specific)
    ../../modules/system/hardware/touchpad.nix
  ];

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.acquisti = {
    isNormalUser = true;
    description = "acquisti";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
  };

  # HOME-MANAGER configuration specific to this host
  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      acquisti = import ../../home/acquisti;
    };
  };

  # Basic network configuration
  networking = {
    extraHosts = ''
      127.0.0.1 baserow.localhost n8n.localhost qdrant.localhost
    '';
    hostName = "acquisti-laptop";
    networkmanager.enable = true;

    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [
        8080 # ERPNext
        3000 # baserow
        5678 # n8n
        6333 # qdrant
      ];
    };
  };

  # Windows network share configs
  services.windowsShares = {
    enable = true;
    shares = {
      scan = {
        enable = true;
        deviceAddress = "//10.40.40.98/scan";
        username = "acquisti";
        mountPoint = "/mnt/scan";
        credentialsFile = "/home/acquisti/nixos/smb-secrets";
      };
      manuali = {
        enable = true;
        deviceAddress = "//10.40.40.98/manuali";
        username = "acquisti";
        mountPoint = "/mnt/manuali";
        credentialsFile = "/home/acquisti/nixos/smb-secrets";
      };
    };
  };

  # Docker containers configuration specific to this host
  virtualisation.dockerSetup = {
    enable = true;
    user = "acquisti";
  };

  system.stateVersion = "24.05";
}
