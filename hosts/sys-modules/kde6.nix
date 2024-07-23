{ pkgs, config, ... }:

{
  # Enable the kde Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  # including some applications from the default install
  environment.systemPackages = with pkgs.kdePackages; [
    # gdrive
    kio-gdrive
    kaccounts-providers
    kaccounts-integration
    ksshaskpass
  ];
  # excluding some applications from the default install
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    # plasma-browser-integration
    # konsole
    # oxygen
  ];

  # services.gnome.gnome-keyring.enable = false;
  # security.pam.services.sddm.enableKwallet = true;
  # programs.kdeconnect.enable = true;
  # programs.ssh.askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

}


