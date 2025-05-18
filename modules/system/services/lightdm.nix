# modules/system/services/gdm.nix
{pkgs, ...}: {
  services.xserver = {
    enable = true;
    displayManager.lightdm = {
      enable = true;
      background = "#000000";
      greeters.gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };
      };
    };
  };
  environment.systemPackages = with pkgs; [
    lightdm
  ];
}
