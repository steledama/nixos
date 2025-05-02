# modules/system/hardware/minibook.nix
# Specific hardware configuration for Chuwi MiniBook X
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Fix for screen orientation
  boot.kernelParams = ["video=DSI-1:panel_orientation=right_side_up"];

  # Enable fractional scaling for the high resolution display
  # GNOME settings
  environment.sessionVariables = {
    # Force the proper driver for Intel graphics for better performance
    MESA_LOADER_DRIVER_OVERRIDE = "iris";
  };

  # Add specific packages useful for the MiniBook
  environment.systemPackages = with pkgs; [
    # For screen rotation based on accelerometer
    iio-sensor-proxy

    # For battery management
    powertop

    # Per gestione monitor
    wlr-randr

    # Per wayland e capturing
    grim
    slurp
  ];

  # Monitor configuration helper service (works with both Niri and GNOME)
  # Creates the script at system level and the service for each user
  system.activationScripts.monitor-config-script = {
    text = ''
            mkdir -p /usr/local/bin
            cat > /usr/local/bin/fix-monitor-layout.sh << 'EOL'
      #!/bin/sh

      # Attendi che i monitor siano rilevati
      sleep 2

      # Log file
      LOG_FILE="/tmp/monitor-layout.log"
      echo "Running monitor layout fix at $(date)" > $LOG_FILE

      # Detect session type
      if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        # Check which compositor is running
        if pgrep -x "niri" > /dev/null; then
          echo "Detected Niri compositor" >> $LOG_FILE

          # Verifica se entrambi i monitor sono connessi
          if wlr-randr | grep -q "DP-2" && wlr-randr | grep -q "DSI-1"; then
            # Imposta la disposizione dei monitor (monitor esterno sopra quello integrato)
            niri-msg output "DP-2" mode "1920x1080" scale 1.0 position x=0 y=0
            niri-msg output "DSI-1" mode "1200x1920" scale 1.5 transform "270" position x=0 y=1080
            echo "Dual monitor configuration applied for Niri" >> $LOG_FILE
          elif wlr-randr | grep -q "DSI-1"; then
            # Solo monitor integrato
            niri-msg output "DSI-1" mode "1200x1920" scale 1.5 transform "270" position x=0 y=0
            echo "Single monitor configuration applied for Niri" >> $LOG_FILE
          fi

        elif pgrep -x "gnome-shell" > /dev/null; then
          echo "Detected GNOME Shell" >> $LOG_FILE

          # GNOME monitor configuration using gsettings
          if wlr-randr | grep -q "DP-2" && wlr-randr | grep -q "DSI-1"; then
            # For GNOME, we use mutter's display configuration
            # Format: monitor-spec output-name x y width height scale rate
            gsettings set org.gnome.mutter.display-configuration applying true

            # Use double quotes for the gsettings command as it needs to pass the string as-is
            gsettings set org.gnome.mutter.display-configuration.DP-2 '{"x": 0, "y": 0, "scale": 1.0, "rotation": 0, "primary": true}'
            gsettings set org.gnome.mutter.display-configuration.DSI-1 '{"x": 0, "y": 1080, "scale": 1.5, "rotation": 3, "primary": false}'

            echo "Dual monitor configuration applied for GNOME" >> $LOG_FILE
          elif wlr-randr | grep -q "DSI-1"; then
            gsettings set org.gnome.mutter.display-configuration.DSI-1 '{"x": 0, "y": 0, "scale": 1.5, "rotation": 3, "primary": true}'
            echo "Single monitor configuration applied for GNOME" >> $LOG_FILE
          fi

        else
          echo "Unknown Wayland compositor, cannot configure monitors" >> $LOG_FILE
        fi
      else
        echo "Not running in Wayland session, cannot configure monitors" >> $LOG_FILE
      fi
      EOL
            chmod +x /usr/local/bin/fix-monitor-layout.sh
    '';
    deps = [];
  };

  # Create a udev rule to run the script when display hardware changes
  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.systemd}/bin/systemctl --no-block start monitor-hotplug.service"
  '';

  # System-wide service to handle monitor hotplug events
  systemd.services.monitor-hotplug = {
    description = "Monitor hotplug handler";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/usr/local/bin/fix-monitor-layout.sh";
      User = "root";
    };
  };

  # Better power management for Intel hardware
  services.thermald.enable = true;

  # Power management
  powerManagement = {
    enable = true;
    powertop.enable = true;

    # Disable USB autosuspend
    powerUpCommands = ''
      # Disable USB autosuspend globally
      echo -1 > /sys/module/usbcore/parameters/autosuspend

      # Find and disable autosuspend for all USB devices
      for usbdev in /sys/bus/usb/devices/*/power/control; do
        echo on > $usbdev
      done
    '';
  };
  # Disable power-profiles-daemon to avoid conflicts with auto-cpufreq
  services.power-profiles-daemon.enable = false;

  # Enable CPU frequency scaling
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # Additional hardware configuration
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Notes:
  # - The tablet mode switch is not currently supported in Linux
  # - The accelerometer works since Linux 6.9.0 but requires additional configuration for auto-rotation
  # - The display may have issues between Linux 6.6.15 and 6.9.0
}
