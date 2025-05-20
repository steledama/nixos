# nixos/hosts/acquisti-laptop/default.nix
{inputs, ...}: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/hardware/intel.nix
    ../../modules/system/hardware/touchpad.nix
    ../../modules/system/services/docker.nix
    ../../modules/system/services/ssh.nix
    ../../modules/system/services/smb.nix
    ../../modules/system/desktop/gnome.nix
    # ../../modules/system/desktop/wm.nix
    # ../../modules/system/desktop/niri.nix
  ];

  # Network
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
        3000 # baserow frontend
        8000 # baserow backend
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

  # User
  users.users.acquisti = {
    isNormalUser = true;
    description = "acquisti";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "video"
    ];
    # shell = pkgs.bash; # Default is zsh uncommet for bash shell
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      acquisti = import ../../home/acquisti;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "";
  };

  # Docker containers
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

  # Keyboard layout
  hardware.keyboard = {
    layout = "no"; # Norwegian layout
    variant = "";
    options = "compose:ralt";
  };

  # System-host-specific packages (additional to common ones)
  # environment.systemPackages = with pkgs; [
  # Add system packages
  # ];

  system.stateVersion = "24.11";
}
