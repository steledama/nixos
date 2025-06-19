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
  ];

  # Network
  networking = {
    hostName = "acquisti-laptop";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # ssh
        80 # wordpress nginx
        443 # wordpress nginx https
        8180 # phpmyadmin
        8080 # baserow http
        # 8443 # baserow https
      ];
      allowPing = true;
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

  system.stateVersion = "24.11";
}
