# modules/system/hardware/scanner.nix
# Scanner stack: SANE backend + NAPS2 (GUI con OCR Tesseract integrato)
{pkgs, ...}: {
  # Enable SANE scanner support
  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.sane-airscan]; # For network scanners if needed
  };

  # Add scanner group to system
  users.groups.scanner = {};

  # Scanner applications and tools
  environment.systemPackages = with pkgs; [
    sane-backends # SANE scanner drivers (includes scanimage CLI)
    naps2 # GUI scanner: profili, batch scan, OCR Tesseract integrato, output PDF/TIFF/PNG
  ];

  # udev rules for Canon scanners (already included in sane-backends, but explicit for clarity)
  services.udev.packages = [pkgs.sane-backends];
}
