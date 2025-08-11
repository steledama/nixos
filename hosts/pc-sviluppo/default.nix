# nixos/hosts/pc-sviluppo/default.nix
{inputs, config, ...}: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/hardware/amd.nix
    ../../modules/system/hardware/touchpad.nix
    ../../modules/system/services/docker.nix
    ../../modules/system/services/ssh.nix
    ../../modules/system/services/xdg-portals.nix
    ../../modules/system/services/smb.nix
    ../../modules/system/services/gdm.nix
    ../../modules/system/desktop/gnome.nix
  ];

  # Configurazione agenix per la gestione dei segreti
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  
  # Definizione del segreto per Samba
  age.secrets.smb-secrets.file = ../../secrets/smb-secrets.age;

  # Network
  networking = {
    hostName = "pc-sviluppo";
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
  users.users.sviluppo = {
    isNormalUser = true;
    description = "sviluppo";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "video"
    ];
  };

  home-manager = {
    users = {
      sviluppo = import ../../home/sviluppo;
    };
  };

  # Docker containers
  virtualisation.dockerSetup = {
    enable = true;
    user = "sviluppo";
  };

  # Windows network share
  services.windowsShares = {
    enable = true;
    shares = {
      scan = {
        enable = true;
        deviceAddress = "//10.40.40.98/scan";
        username = "sviluppo";
        mountPoint = "/mnt/scan";
        credentialsFile = config.age.secrets.smb-secrets.path;
      };
      manuali = {
        enable = true;
        deviceAddress = "//10.40.40.98/manuali";
        username = "sviluppo";
        mountPoint = "/mnt/manuali";
        credentialsFile = config.age.secrets.smb-secrets.path;
      };
    };
  };

  # Keyboard layout
  hardware.keyboard = {
    layout = "it"; # Italian layout
    variant = "";
    options = "compose:ralt";
  };

  system.stateVersion = "25.05";
}
