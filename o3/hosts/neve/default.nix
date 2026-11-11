# hosts/neve/default.nix
{pkgs, ...}: {
  # UNFREE: unrar for extracting .rar archives (torrent downloads)
  # (chromium/widevine arrivano da gui-apps.nix)
  unfree.allowedNames = ["unrar"];

  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/home-vpn-route.nix
    ../../modules/system/hardware/intel.nix
    ../../modules/system/hardware/scanner.nix
  ];

  # Bluetooth support for external speakers
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Load IT87 chipset module for fan speed monitoring and PWM control
  # Gigabyte H170N-WIFI uses ITE IT8628 Super I/O chip
  boot.kernelModules = ["it87"];

  # Fan control: minimum PWM below 60°C, linear ramp 60-80°C, full speed above 80°C
  # hwmon0 = it8628 (fans/PWM), hwmon2 = coretemp (CPU temperature)
  hardware.fancontrol = {
    enable = true;
    config = ''
      INTERVAL=10
      DEVPATH=hwmon0=devices/platform/it87.2624 hwmon2=devices/platform/coretemp.0
      DEVNAME=hwmon0=it8628 hwmon2=coretemp
      FCTEMPS=hwmon0/pwm1=hwmon2/temp1_input hwmon0/pwm2=hwmon2/temp1_input
      FCFANS=hwmon0/pwm1=hwmon0/fan1_input hwmon0/pwm2=hwmon0/fan2_input
      MINTEMP=hwmon0/pwm1=60 hwmon0/pwm2=60
      MAXTEMP=hwmon0/pwm1=80 hwmon0/pwm2=80
      MINSTART=hwmon0/pwm1=70 hwmon0/pwm2=70
      MINSTOP=hwmon0/pwm1=70 hwmon0/pwm2=70
      MINPWM=hwmon0/pwm1=70 hwmon0/pwm2=70
      MAXPWM=hwmon0/pwm1=255 hwmon0/pwm2=255
    '';
  };

  # Archive tools
  environment.systemPackages = with pkgs; [
    unrar # Extract .rar archives
  ];

  # Disable Energy-Efficient Ethernet on the onboard Intel I219 (e1000e).
  # With EEE active the PHY leaves the switch port in a low-power state on
  # shutdown/suspend that some switches never exit from (requires power-cycling
  # the switch to restore link). Re-run after resume: the link renegotiates.
  systemd.services.disable-eee-enp0s31f6 = {
    description = "Disable EEE on enp0s31f6 (switch port gets stuck in low-power state)";
    wantedBy = ["multi-user.target" "post-resume.target"];
    after = ["sys-subsystem-net-devices-enp0s31f6.device" "post-resume.target"];
    requires = ["sys-subsystem-net-devices-enp0s31f6.device"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool --set-eee enp0s31f6 eee off";
    };
  };

  # Broken USB port 1-3 on the xHCI roothub (0000:00:14.0): a phantom device never
  # enumerates and, while failing, times out the controller command ring — the same
  # controller keyboard/mouse/scanner hang off — freezing all input for ~90s at boot.
  #
  # The fix must land BEFORE the kernel builds up its enumeration retry storm, so it
  # lives in the initrd as a udev rule: the instant the roothub hub binds (ports now
  # exist, downstream enumeration just starting) we set `early_stop` (kernel cuts the
  # retries short instead of looping for ~90s) and `disable` the port outright. A
  # post-boot systemd service is too late — its sysfs write serializes behind the
  # already-stalled command ring and only returns after the port gives up on its own.
  boot.initrd.services.udev.rules = ''
    ACTION=="bind", SUBSYSTEM=="usb", KERNEL=="1-0:1.0", ATTR{usb1-port3/early_stop}="yes", ATTR{usb1-port3/disable}="1"
  '';

  # Runtime backstop: re-apply after resume (initrd does not re-run) and cover any
  # late hotplug re-enumeration. Not the boot-time fix — see the initrd rule above.
  systemd.services.disable-broken-usb-port = {
    description = "Disable broken USB port 1-3 (runtime/resume backstop; boot fix is in initrd)";
    wantedBy = ["multi-user.target" "post-resume.target"];
    after = ["systemd-udevd.service" "post-resume.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo yes > /sys/bus/usb/devices/1-0:1.0/usb1-port3/early_stop; echo 1 > /sys/bus/usb/devices/1-0:1.0/usb1-port3/disable'";
      RemainAfterExit = true;
    };
  };

  networking.hostName = "neve";

  # Keyboard configuration (Italian layout)
  console.keyMap = "it";
  # Wayland keyboard layout configured in the Niri user config

  # Scanner access (l'utente è nella baseline)
  users.users.stele.extraGroups = ["scanner" "lp"];

  system.stateVersion = "25.11";
}
