{
  # Bootloader
  boot.loader.systemd-boot = {
    enable = true;
    # Limit number of generations in /boot to prevent filling up ESP
    configurationLimit = 10;
  };
  # Show boot menu for 5 seconds - allows selecting alternative generations
  # Without this, systemd-boot boots immediately with no recovery option
  boot.loader.timeout = 5;
  boot.loader.efi.canTouchEfiVariables = true;
}
