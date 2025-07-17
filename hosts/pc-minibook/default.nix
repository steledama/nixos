# nixos/hosts/pc-minibook/default.nix
{inputs, ...}: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/hardware/intel.nix
    ../../modules/system/hardware/touchpad.nix
    ../../modules/system/hardware/minibook.nix
    ../../modules/system/services/docker.nix
    ../../modules/system/services/ssh.nix
    ../../modules/system/services/xdg-portals.nix
    ../../modules/system/services/gdm.nix
    ../../modules/system/desktop/gnome.nix
    ../../modules/system/desktop/wm.nix
    # ../../modules/system/desktop/niri.nix
  ];

  # Network
  networking = {
    hostName = "pc-minibook";
    networkmanager = {
      enable = true;
    };
  };

  # User
  users.users.stele = {
    isNormalUser = true;
    description = "stele";
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
      stele = import ../../home/stele;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "";
  };

  # Docker containers
  virtualisation.dockerSetup = {
    enable = true;
    user = "stele";
  };

  # System-host-specific packages (additional to common ones)
  # environment.systemPackages = with pkgs; [
  # Add system packages
  # ];

  system.stateVersion = "24.11";
}
