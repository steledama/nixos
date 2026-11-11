# hosts/game/default.nix
# Gaming PC with NVIDIA RTX 4070 - dual boot with Windows
{
  pkgs,
  lib,
  identity,
  ...
}: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/home-vpn-route.nix
    ../../modules/system/hardware/nvidia.nix
    ../../modules/system/hardware/touchpad.nix # Remove if no touchpad
    ../../modules/system/services/docker.nix
    ../../modules/system/services/llama-cpp.nix
    ../../modules/system/gaming.nix
    ../../modules/system/hardware/openrgb.nix
  ];

  # Syncthing user lingering (enable in o3/hosts/default.nix)
  services.userLinger.users = ["stele"];

  # Pacchetti unfree dichiarati nei moduli che li installano:
  # nvidia.nix (driver + CUDA), gaming.nix (Steam), gui-apps.nix (chromium).

  # Dual boot: NTFS support for accessing Windows partitions
  boot.supportedFilesystems = ["ntfs"];

  # Keep the RTC in UTC. Windows dual boot must use RealTimeIsUniversal.
  # Local-time RTC made the clock jump back after NTP sync, invalidating OAuth.

  # Windows entry in systemd-boot menu
  # FS1 is the Windows EFI partition (PARTUUID: 1e5bbc53-f785-4ae2-909f-c209d4f78bb8).
  boot.loader.systemd-boot.windows."windows" = {
    title = "Windows";
    efiDeviceHandle = "FS1";
  };

  # Memtest86+ entry in systemd-boot menu, to validate the 48 GB RAM upgrade.
  boot.loader.systemd-boot.memtest86.enable = true;

  # Set Windows as default boot entry — runs after every nixos-rebuild.
  # The windows."windows" entry above is written by NixOS as windows_windows.conf
  # (file name = "windows_" + attribute name), so the default must match that id.
  boot.loader.systemd-boot.extraInstallCommands = ''
    ${pkgs.systemd}/bin/bootctl set-default windows_windows.conf
  '';

  # Niri auto-login user (compositor enabled in o3/hosts/default.nix)
  services.niriDesktop.autoLoginUser = "stele";

  # RGB lighting control (RAM, GPU, motherboard)
  hardware.openrgbControl.enable = true;

  # Local LLM/OCR server. Access is restricted to LAN/VPN by iptables below.
  services.llamaCppServer = {
    enable = true;
    autoStart = false; # avvio a mano all'occorrenza: sudo systemctl start llama-cpp
    host = "0.0.0.0"; # LAN access (ristretto via iptables)
    port = 11434;
    chatContextSize = 32768;
    ocrContextSize = 8192;
  };

  # Network (networkmanager + firewall enable in o3/hosts/default.nix)
  networking = {
    hostName = "game";
    firewall = {
      allowedTCPPorts = [
        22 # SSH
        22000 # Syncthing sync
      ];
      # LAN-only services (deck, game stesso)
      extraCommands = ''
        # llama.cpp (11434)
        iptables -A nixos-fw -s ${identity.home.lan.subnet} -p tcp --dport 11434 -j nixos-fw-accept
        iptables -A nixos-fw -s 172.16.0.0/12 -p tcp --dport 11434 -j nixos-fw-accept
        # ComfyUI (8188)
        iptables -A nixos-fw -s ${identity.home.lan.subnet} -p tcp --dport 8188 -j nixos-fw-accept
        iptables -A nixos-fw -s 172.16.0.0/12 -p tcp --dport 8188 -j nixos-fw-accept
      '';
    };
  };

  # Keyboard configuration (Italian layout)
  console.keyMap = "it";
  # Wayland keyboard layout configured in Niri/Sway user configs

  # User: stele (custode e familiare), come su deck e neve. Fino al 2026-11-07
  # era utente-precedente; i figli usano Windows (custode). L'UID è quello di utente-precedente, così
  # la home spostata da /home/utente-precedente resta dell'utente senza chown.
  users.users.stele = {
    isNormalUser = true;
    uid = 1000;
    description = "stele";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "video"
      "i2c" # RGB control via OpenRGB
    ];
    openssh.authorizedKeys.keys = lib.attrValues identity.home.gameAuthorizedKeys;
  };

  # Docker containers
  virtualisation.dockerSetup = {
    enable = true;
    user = "stele";
    enableNvidia = true; # Enable NVIDIA container toolkit
    pruneKeepLabel = "prune.keep"; # ComfyUI (~/comfyui) fermo fra un uso e l'altro
  };

  # Tool CLI specifici di game
  environment.systemPackages = with pkgs; [
    whisper-cpp # Trascrizione audio con CUDA (cudaSupport attivato in nvidia.nix)
  ];

  system.stateVersion = "25.11";
}
