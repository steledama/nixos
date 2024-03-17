{ pkgs, config, ... }:

{
  # Enable the kde Desktop Environment.
  services.desktopManager.plasma5.enable = true;
  # including some applications from the default install
  environment.systemPackages = with pkgs.libsForQt5; [
    # gdrive
    kio-gdrive
    kaccounts-providers
    kaccounts-integration
  ];
  # excluding some applications from the default install
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
  # plasma-browser-integration
  # konsole
  # oxygen
];
qt = {
  enable = true;
  platformTheme = "gnome";
  style = "adwaita-dark";
};
}

