# nixos/hosts/pcgame/default.nix
{inputs, ...}: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/hardware/nvidia.nix
    ../../modules/system/services/docker.nix
    ../../modules/system/services/ssh.nix
    ../../modules/system/services/ollama.nix
    ../../modules/system/services/gdm.nix
    ../../modules/system/desktop/gnome.nix
    ../../modules/system/desktop/wayland-wm.nix
  ];

  # Network
  networking = {
    hostName = "pcgame";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        4662 # aMule eD2K data
        4672 # aMule incoming connections
        11435 # msty ollama service for llm
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
    backupFileExtension = "backup";
  };

  # Docker containers
  virtualisation.dockerSetup = {
    enable = true;
    user = "stefano";
    enableNvidia = true;
  };

  # Windows managers
  wayland-wm = {
    enable = true;
    enableHyprland = true;
    enableNiri = true;
  };
  programs.niri.enable = true;

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "24.05"; # Did you read the comment?
}
