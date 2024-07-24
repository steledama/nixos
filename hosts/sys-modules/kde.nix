{ pkgs, config, lib, ... }:

let
  plasma5Enabled = config.services.desktopManager.plasma5.enable;
  plasma6Enabled = config.services.desktopManager.plasma6.enable;
in
{
  services.xserver = {
    enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  # Choose your Plasma version by uncommenting ONE of the following blocks:

  # For Plasma 5:
  services.desktopManager.plasma5.enable = true;
  services.desktopManager.plasma6.enable = false;

  # For Plasma 6:
  # services.desktopManager.plasma5.enable = false;
  # services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    # Common KDE packages
  ] ++ (if plasma5Enabled then [
    # Plasma 5 specific packages
  ] else if plasma6Enabled then [
    libsForQt5.kio-gdrive
    libsForQt5.kaccounts-providers
    libsForQt5.kaccounts-integration
    # Plasma 6 specific packages
    kdePackages.kio-gdrive
    kdePackages.kaccounts-providers
    kdePackages.kaccounts-integration
    kdePackages.ksshaskpass
  ] else [ ]);

  environment = {
    plasma5.excludePackages = lib.mkIf plasma5Enabled (with pkgs.libsForQt5; [
      oxygen
      # Add other Plasma 5 specific exclusions here
    ]);

    plasma6.excludePackages = lib.mkIf plasma6Enabled (with pkgs.kdePackages; [
      oxygen
      # Add other Plasma 6 specific exclusions here
    ]);
  };

  # Common package exclusions
  environment.systemPackages = lib.mkForce (lib.subtractLists
    [
      # List common packages to exclude for both Plasma 5 and 6
    ]
    config.environment.systemPackages
  );
}
