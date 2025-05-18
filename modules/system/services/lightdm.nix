# modules/system/services/lightdm.nix
{pkgs, ...}: {
  services.xserver.displayManager.lightdm = {
    enable = true;
    background = "#000000";
    greeters.gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.gnome-themes-extra;
      };
    };
  };
  environment.systemPackages = with pkgs; [
    lightdm
  ];
}
