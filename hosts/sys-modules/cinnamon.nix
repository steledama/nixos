{ pkgs, config, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.lightdm = {
      enable = true;
      # You can add more LightDM configurations here if needed
    };
    desktopManager.cinnamon.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Add any Cinnamon-specific packages here
    gnome-online-accounts # account google
    gvfs # virtual filesystem support libnrary for google drive
  ];
}


