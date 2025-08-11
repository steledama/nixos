# In configuration.nix (livello sistema)
{pkgs, ...}: {
  # Configurazione hardware Intel
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      (vaapiIntel.override {enableHybridCodec = true;})
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
