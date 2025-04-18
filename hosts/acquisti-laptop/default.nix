# nixos/hosts/acquisti-laptop/default.nix
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/hardware/intel.nix
    ../../modules/system/hardware/touchpad.nix
    ../../modules/system/services/docker.nix
    ../../modules/system/services/ssh.nix
    ../../modules/system/services/smb.nix
    ../../modules/system/services/gdm.nix
    ../../modules/system/desktop/gnome.nix
  ];

  # Network configuration
  networking = {
    hostName = "acquisti-laptop";

    networkmanager = {
      enable = true;
      settings = {
        "connection" = {
          "ethernet.route-metric" = 100;
          "wifi.route-metric" = 200;
        };
      };
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # ssh
        80 # wordpress
        443 # https
      ];
      allowPing = true;
      logRefusedConnections = true;
      logRefusedPackets = true;
    };

    hosts = {
      "127.0.0.1" = [
        "5.89.62.125" # work pubblic
        "10.40.40.130" # work eth (reserved)
        "192.168.1.16" # home wifi ((reserved))
      ];
    };
  };

  # Keyboard layout (default is us international)
  hardware.keyboard = {
    layout = "no"; # Norwegian layout
    variant = "";
    options = "compose:ralt";
  };

  # User
  users.users.acquisti = {
    isNormalUser = true;
    description = "acquisti";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    # shell = pkgs.bash; # Default is zsh uncommet for bash shell
  };

  # Home manager
  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      acquisti = import ../../home/acquisti;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };

  # Docker containers configuration specific to this host
  virtualisation.dockerSetup = {
    enable = true;
    user = "acquisti";
  };

  # Windows network share
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

  # System-host-specific packages (additional to common ones)
  # environment.systemPackages = with pkgs; [
  # Add system packages
  # ];

  system.stateVersion = "24.05";
}
