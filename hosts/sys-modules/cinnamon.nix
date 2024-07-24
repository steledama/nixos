{ pkgs, config, ... }:

{
  services.xserver = {
    enable = true;
    # Italian keyboard
    xkb.layout = "it";
    xkb.Variant = "";
    # Lightdm display manager
    displayManager.lightdm = {
      enable = true;
      # Puoi aggiungere altre configurazioni LightDM qui se necessario
    };
    # Cinnamon desktop environment
    desktopManager.cinnamon.enable = true;
  };

  # LightDM greatings it
  services.xserver.displayManager.lightdm.greeters.gtk = {
    extraConfig = ''
      [greeter]
      keyboard=it
    '';
  };

  environment.systemPackages = with pkgs; [
    # Cinnamon specific system packages
    gnome-online-accounts # account google
    gvfs # virtual filesystem support library for google drive
  ];
}


