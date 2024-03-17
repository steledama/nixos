{ pkgs, config, ... }:

{
  # Enable the kde Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  # including some applications from the default install
  environment.plasma6.systemPackages = with pkgs.kdePackages; [
    # gdrive
    kio-gdrive
    kaccounts-providers
    kaccounts-integration
  ];
  # excluding some applications from the default install
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
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

