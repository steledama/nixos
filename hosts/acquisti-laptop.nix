# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [
      # host hardware scan result
      ./hw-acquisti-laptop.nix
      # kernel zen (comment out for default kernel)
      ./sys-modules/zen.nix
      # GPU (choose one)
      # gpu nvidia
      # ./sys-modules/nvidia.nix
      # gpu amd
      # ./sys-modules/amd.nix
      # gpu intel
      ./sys-modules/intel.nix
      # boot
      ./sys-modules/boot.nix
      # locale
      ./sys-modules/it.nix
      # networking
      ./sys-modules/networking.nix
      # nix
      ./sys-modules/nix.nix
      # sound
      ./sys-modules/sound.nix
      # print
      ./sys-modules/print.nix
      # ssh
      # ./sys-modules/ssh.nix
      # Display Manager
      # sddm (kde and hyprland)
      ./sys-modules/sddm.nix
      # gdm (gnome)
      # ./sys-modules/gdm.nix
      # Desktop Environmnet
      # kde
      ./sys-modules/kde6.nix
      # ./sys-modules/kde5.nix
      # gnome
      # ./sys-modules/gnome.nix
      # home manager
      inputs.home-manager.nixosModules.default
    ];
  # HOSTNAME
  networking.hostName = "nixos"; # Define your hostname.

    # allow unfree software
  nixpkgs.config.allowUnfree = true;
    # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # terminal editor
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
  users.users.ttacquisti = {
    isNormalUser = true;
    description = "ttacquisti";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  home-manager =
    {
      # also pass inputs to home-manager modules
      extraSpecialArgs = { inherit inputs; };
      users = {
        ttacquisti = import ../users/ttacquisti.nix;
      };
    };

      # syncthing
  services = {
    syncthing = {
      enable = true;
      user = "ttacquisti";
      dataDir = "/home/ttacquisti"; # Default folder for new synced folders
      configDir = "/home/ttacquisti/.config/syncthing"; # Folder for Syncthing's settings and keys
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
