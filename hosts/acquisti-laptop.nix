# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      # HOME MANAGER
      inputs.home-manager.nixosModules.default

      # HARDWARE
      ./hw/hardware-acquisti-laptop.nix

      # KERNEL (comment out for default kernel)
      ./sys-modules/zen.nix

      # GPU (choose one)
      ./sys-modules/intel.nix
      # ./sys-modules/nvidia.nix
      # ./sys-modules/amd.nix

      # DE: Desktop Environment (choose one)
      # ./sys-modules/cinnamon.nix
      ./sys-modules/gnome.nix
      # ./sys-modules/kde.nix

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
      # virtual machine
      ./sys-modules/vm.nix
      # fonts
      ./sys-modules/fonts.nix
      # touchpad
      ./sys-modules/touchpad.nix
      # ssh
      # ./sys-modules/ssh.nix
      # gaming
      # ./sys-modules/gaming.nix
      # SMB (Windows network share)
      ./sys-modules/smb.nix
    ];

  # NETWORKING
  # hostname
  networking.hostName = "acquisti-laptop"; # Define your hostname.
  # networkmanager
  networking.networkmanager.enable = true;
  # Enables wireless support via wpa_supplicant.
  # networking.wireless.enable = true;
  # bridge for virtual network
  # networking.interfaces.enp7s0.useDHCP = false;
  # networking.bridges = {
  #   "br0" = {
  #     interfaces = [ "enp7s0" ];
  #   };
  # };
  # networking.interfaces.br0.ipv4.addresses = [{
  #   address = "192.168.1.27";
  #   prefixLength = 24;
  # }];
  # networking.defaultGateway = "192.168.1.1";
  # networking.nameservers = [ "192.168.1.1" "8.8.8.8" ];
  # proxy
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # allow unfree software
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget # Tool for retrieving files using HTTP, HTTPS, and FTP
    git # version control
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.acquisti = {
    isNormalUser = true;
    description = "acquisti";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
  };

  # HOME-MANAGER as module
  home-manager =
    {
      # also pass inputs to home-manager modules
      extraSpecialArgs = { inherit inputs; };
      users = {
        acquisti = import ../users/acquisti.nix;
      };
    };

  # Service fo fix home monitor resolution
  systemd.services.display-setup = {
    description = "Set up display resolutions for Acquisti Laptop";
    wantedBy = [ "multi-user.target" ];
    before = [ "display-manager.service" ];
    script = builtins.readFile ./acquisti-laptop-monitor.sh;
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
  # check service status:
  # systemctl status display-setup
  # check service log
  # journalctl -u display-setup

  # Windows Network Share Configuration
  # This section configures the mounting of a Windows SMB share.
  # You can add multiple share configurations by duplicating this block and changing the settings.
  # For advanced options, see the SMB module file at ./sys-modules/smb.nix
  services.windowsShare = {
    enable = true;
    deviceAddress = "//10.40.40.98/scan";
    username = "acquisti";
    # Optional: you can overwrite the default mount point if needed
    # mountPoint = "/mnt/windowsshare";
    # Optional: you can specify a custom path for the credentials file
    # credentialsFile = "/etc/nixos/smb-secrets";
    credentialsFile = "/home/acquisti/nixos/smb-secrets";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
