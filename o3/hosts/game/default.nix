# hosts/game/default.nix
# Gaming PC with NVIDIA RTX 4070 - dual boot with Windows
{
  pkgs,
  identity,
  ...
}: {
  imports = [
    ./hardware.nix
    ../default.nix
    ../../modules/system/home-vpn-route.nix
    ../../modules/system/hardware/nvidia.nix
    ../../modules/system/services/docker.nix
    ../../modules/system/services/llama-cpp.nix
    ../../modules/system/gaming.nix
    ../../modules/system/hardware/openrgb.nix
  ];

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
      # LAN-only services. I peer della VPN casa arrivano mascherati dal NAT
      # di deck, quindi con sorgente LAN.
      extraCommands = ''
        # llama.cpp (11434)
        iptables -A nixos-fw -s ${identity.home.lan.subnet} -p tcp --dport 11434 -j nixos-fw-accept
        # ComfyUI (8188)
        iptables -A nixos-fw -s ${identity.home.lan.subnet} -p tcp --dport 8188 -j nixos-fw-accept
      '';
    };
  };

  # Keyboard configuration (Italian layout)
  console.keyMap = "it";
  # Wayland keyboard layout configured in the Niri user config

  # L'utente è nella baseline. Qui l'UID è fissato: fino al 2026-11-07 era
  # utente-precedente, e la home spostata da /home/utente-precedente resta
  # sua senza chown solo se l'UID non cambia.
  users.users.stele = {
    uid = 1000;
    extraGroups = ["i2c"]; # RGB control via OpenRGB
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
