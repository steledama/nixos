# In configuration.nix (livello sistema)
{pkgs, ...}: {
  # Configurazione hardware Intel
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      (intel-vaapi-driver.override {enableHybridCodec = true;})
      libva-vdpau-driver
    ];
  };
}
