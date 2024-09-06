# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, inputs, ... }:

{
  imports =
    [
      # HOME MANAGER
      inputs.home-manager.nixosModules.default

      # HARDWARE
      ./hw/hardware-pcgame.nix

      # KERNEL (comment out for default kernel)
      ./sys-modules/zen.nix

      # GPU (choose one)
      # ./sys-modules/intel.nix
      ./sys-modules/nvidia.nix
      # ./sys-modules/amd.nix

      # DE: Desktop Environment
      ./sys-modules/gnome.nix

      # fonts
      ./sys-modules/fonts.nix
      # boot
      ./sys-modules/boot.nix
      # locale
      ./sys-modules/it.nix
      # nix
      ./sys-modules/nix.nix
      # sound
      ./sys-modules/sound.nix
      # print
      ./sys-modules/print.nix
      # smb (windows network share)
      # ./sys-modules/smb.nix
      # network (uncomment only in case of static or bridge configuration)
      # ./sys-modules/network.nix
      # virtualization
      # ./sys-modules/vm.nix
      # containers
      ./sys-modules/docker.nix
      # ssh
      # ./sys-modules/ssh.nix
      # touchpad
      # ./sys-modules/touchpad.nix
      # gaming
      ./sys-modules/gaming.nix
    ];

  # allow unfree software
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git # Version control
    lazygit # Git frontend
    neovim # Terminal editor
    nil # Nix language server
    nixpkgs-fmt # Code formater for nix
    wget # Tool for retrieving files using HTTP, HTTPS, and FTP
    unzip # An extraction utility for archives compressed in .zip format
    usbimager # Utility to flash os iso images on usb drive
    gcc # C compiler
    lsof # Tool to list open files
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.stefano = {
    isNormalUser = true;
    description = "stefano";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
  };

  # containers
  virtualisation.dockerSetup = {
    enable = true;
    user = "stefano";
  };

  # HOME-MANAGER as module
  home-manager =
    {
      # also pass inputs to home-manager modules
      extraSpecialArgs = { inherit inputs; };
      users = {
        stefano = import ../users/stefano.nix;
      };
      # Existing configs backup
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };

  # Basic network configuration
  networking = {
    hostName = "pcgame";
    # comment out in case of static or bridge network config
    networkmanager.enable = true;
  };

  # Static or bridge network configs (uncomment the module above and configure)
  # networking.customSetup = {
  #   # Define a static IP address:
  #   staticIP.address = "192.168.1.27";
  #   # Note: Default prefix length is 24, change in network.nix if needed
  #   
  #   # Define the default gateway:
  #   gateway = "192.168.1.1";
  #   
  #   # Define DNS servers:
  #   nameservers = [ "192.168.1.1" "8.8.8.8" ];
  #   
  #   # Uncomment one of the following types:
  #   type = "static";
  #   # type = "bridge"; # only needed in case of virtual module uncommented (vm.nix)
  #   
  #   # For bridge configuration:
  #   # bridgeConfig.name = "br0";
  #   
  #   # Specify interface only if automatic detection fails:
  #   # interface = "enp7s0";
  #   # To discover network interfaces, you can use these commands:
  #   # - 'ip link show' (shows all network interfaces)
  #   # - 'ls /sys/class/net' (lists network interfaces)
  #   # - 'networkctl list' (shows network interfaces and their status)
  # };

  # Windows Network Share Configuration (uncomment the module smb.nix above and configure)
  # This section configures the mounting of a Windows SMB share.
  # You can add multiple share configurations by duplicating this block and changing the settings.
  # For advanced options, see the SMB module file at ./sys-modules/smb.nix
  # services.windowsShare = {
  #   enable = true;
  #   deviceAddress = "//192.168.1.1/share";
  #   username = "stefano";
  #   # Optional: you can overwrite the default mount point if needed
  #   # mountPoint = "/mnt/windowsshare";
  #   # Optional: you can specify a custom path for the credentials file
  #   # credentialsFile = "/etc/nixos/smb-secrets";
  #   credentialsFile = "/home/stefano/nixos/smb-secrets";
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
