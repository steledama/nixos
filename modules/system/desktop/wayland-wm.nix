# modules/system/desktop/wayland-wm.nix
# System-level configuration for Wayland window managers
{
  pkgs,
  lib,
  config,
  ...
}: 

let
  cfg = config.wayland-wm;
in {
  options.wayland-wm = {
    enable = lib.mkEnableOption "Enable Wayland window managers";
    
    enableHyprland = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Hyprland at the system level";
    };
    
    enableNiri = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Niri at the system level";
    };
  };

  config = lib.mkIf cfg.enable {

      environment.sessionVariables = {
    # Abilita il backend Wayland per Electron
    NIXOS_OZONE_WL = "1";
    # Per applicazioni Electron più vecchie
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    # Per applicazioni che richiedono accelerazione hardware
    ELECTRON_ENABLE_LOGGING = "1";  # Per il debug
    # Compatibilità con NVIDIA (anche se non hai NVIDIA, può aiutare in alcuni casi)
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    # Variabili per strumenti di debug
    LIBGL_DEBUG = "verbose";
  };
  
    # Ensure XDG Portal is set up correctly
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ] ++ lib.optional cfg.enableHyprland pkgs.xdg-desktop-portal-hyprland;
    };

    # Enable the WMs at the system level if requested
    programs = {
      hyprland = lib.mkIf cfg.enableHyprland {
        enable = true;
        xwayland.enable = true;
      };
      
      niri = lib.mkIf cfg.enableNiri {
        enable = true;
        package = pkgs.niri-unstable;
      };
    };

    # Common packages needed by Wayland WMs
    environment.systemPackages = with pkgs; [
      # Core Wayland utilities
      wl-clipboard
      wlr-randr
      wayland-utils
      
      # Notification system
      libnotify
      
      # Screenshot and screen recording
      grim
      slurp
      
      # Brightness and volume control
      pamixer
      brightnessctl
    ];

    # Ensure polkit is available for authentication dialogs
    security.polkit.enable = true;
    
    # Services needed by Wayland compositors
    services = {
      # Required for XDG desktop integration
      dbus.enable = true;
      
      # Optional services that most Wayland setups need
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };
  };
}
