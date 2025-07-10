# nixos/hosts/pc-game/default.nix
{inputs, ...}: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/hardware/nvidia.nix
    ../../modules/system/services/docker.nix
    ../../modules/system/services/ssh.nix
    ../../modules/system/services/ollama.nix
    ../../modules/system/desktop/gnome.nix
    ../../modules/system/desktop/wm.nix
    ../../modules/system/desktop/niri.nix
    ../../modules/system/desktop/hyprland.nix
  ];

  # Network
  networking = {
    hostName = "pc-game";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        4662 # aMule eD2K data
        4672 # aMule incoming connections
        11343 # ollama
        3080 # librechat
      ];
      allowedUDPPorts = [
        4665 # aMule eD2K
        4672 # aMule Kad
      ];
    };
  };

  # User
  users.users.stefano = {
    isNormalUser = true;
    description = "stefano";
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
      stefano = import ../../home/stefano;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "";
  };

  # Docker containers
  virtualisation.dockerSetup = {
    enable = true;
    user = "stefano";
    enableNvidia = true;
  };

  # Keyboard layout (default is us international)
  hardware.keyboard = {
    layout = "it";
    variant = "";
    options = "";
  };

  # ollama
  extraServices.ollama.enable = true;

  # System-host-specific packages (additional to common ones)
  # environment.systemPackages = with pkgs; [
  # Add system packages
  # ];

  system.stateVersion = "24.11";
}
