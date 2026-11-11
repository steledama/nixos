# o3/hosts/default.nix
{
  config,
  pkgs,
  lib,
  self,
  identity,
  ...
}: {
  # Il flake senza override valuta e costruisce i template pubblici
  # (nix flake check), ma non deve mai attivarli: con chiavi e indirizzi
  # segnaposto un host reale resterebbe senza accesso SSH. Il controllo
  # ferma switch, boot e test prima di toccare il sistema; con l'identità
  # locale non esiste e il toplevel non cambia.
  system.preSwitchChecks = lib.mkIf (identity.template or false) {
    identitaReale = ''
      echo "Identità di esempio: questa configurazione usa i template pubblici di o3/identity." >&2
      echo "Attivare con o3/scripts/con-identita.sh sudo nixos-rebuild ... (o3/identity/README.md)." >&2
      exit 1
    '';
  };

  # Provenienza del codice pubblico, letta da o3/scripts/system-drift.sh.
  # Con l'identità locale (con-identita.sh: --override-input, lock non
  # scritto) Nix toglie rev da self anche a checkout pulito; resta narHash,
  # l'hash dei soli file tracciati, che identifica il contenuto senza dire nulla
  # dell'identità. Valori: <rev> (pulito, senza override), <rev>-dirty
  # (albero modificato, con o senza override), nar:<narHash> (pulito, con
  # override). Lo script cerca un commit con lo stesso contenuto, senza
  # attribuire un commit d'origine univoco o un albero modificato per esclusione.
  system.configurationRevision = self.rev or self.dirtyRev or "nar:${self.narHash}";

  # Common system modules for every host (deck, game, neve).
  imports = [
    ../modules/system/boot.nix
    ../modules/system/unfree.nix
    ../modules/system/nix.nix
    ../modules/system/shell.nix
    ../modules/system/fonts.nix
    ../modules/system/locale.nix # default it
    ../modules/system/hardware/sound.nix
    ../modules/system/services/print.nix
    ../modules/system/services/user-linger.nix
    ../modules/system/host-names.nix
    ../modules/system/niri.nix
    ../modules/system/gui-apps.nix
    ../modules/system/hardware/printer-ricoh-im550.nix
  ];

  # The three hosts are desktops of the same user: account, auto-login into
  # Niri, lingering (Syncthing without an interactive login) and who may log
  # in over SSH are declared once. A host file only adds its extra groups.
  users.users.stele = {
    isNormalUser = true;
    description = "stele";
    extraGroups = ["networkmanager" "wheel" "video"];
    openssh.authorizedKeys.keys = lib.attrValues identity.home."${config.networking.hostName}AuthorizedKeys";
  };
  services.niriDesktop.autoLoginUser = "stele";
  services.userLinger.users = ["stele"];

  # NetworkManager plus a ping-friendly firewall on every host; host files add
  # their own ports, static profiles and extra rules. SSH opens its own port.
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [22000]; # Syncthing sync
    # serve.py lanciato a mano (o3/presentations.nix) dalla LAN casa: i peer della
    # VPN casa arrivano mascherati dal NAT di deck, con la sua sorgente LAN.
    extraCommands = ''
      iptables -A nixos-fw -s ${identity.home.lan.subnet} -p tcp --dport ${toString (import ../presentations.nix).manualPort} -j nixos-fw-accept
    '';
  };

  # SSH - enabled on all hosts.
  # Solo autenticazione a chiave: le authorized_keys sono distribuite su tutti
  # gli host (kb/ssh-matrix.md), la password non serve e abilita il brute force.
  services.openssh = {
    enable = true;
    # Chi entra lo decide solo il repo: ~/.ssh/authorized_keys viene ignorato,
    # ogni chiave passa da commit e rebuild (kb/ssh-matrix.md).
    authorizedKeysInHomedir = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  programs.ssh.systemd-ssh-proxy.enable = false;

  # Kernel configuration
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # FUSE - required for rclone mount (user-space filesystem)
  programs.fuse = {
    enable = true;
    userAllowOther = true;
  };

  # Polkit configuration (required by GUI apps like gparted, GNOME Disks, etc.)
  security.polkit.enable = true;

  # Common system packages
  environment.systemPackages = with pkgs; [
    # Build dependencies for compiling native modules (npm, pip, cargo)
    gcc # C compiler
    openssl # Cryptographic library
    libxml2 # XML toolkit

    # Runtime for Node.js projects
    nodejs_24

    # System monitoring and diagnostics
    btop # Resource monitor (CPU, memory, disks, network, processes)
    dmidecode # Hardware information from BIOS/UEFI (motherboard, CPU, RAM slots)
    hdparm # Disk performance benchmarking and drive parameter control (SATA)
    nvme-cli # NVMe drive info and management (nvme id-ctrl, smart-log)
    iotop # I/O usage monitoring
    lm_sensors # Hardware sensors reading
    lsof # Tool to list open files
    pciutils # Tools for inspecting PCI devices (includes lspci)
    usbutils # Tools for inspecting USB devices (includes lsusb)
    wev # Wayland event viewer

    # System management and utilities
    efibootmgr # EFI Boot Manager utility
    file # Identify file types by content (magic bytes)
    findutils # For find command
    coreutils # For basic Unix utilities
    bc # Arbitrary precision calculator language (useful in shell scripts)
    which # Locate a program in the user's path
    psmisc # Set of small useful utilities that use the proc filesystem (killall)
    zip # Compressor/archiver for creating and modifying zipfiles
    parted # Disk partitioning utility (includes partprobe)
    exfatprogs # exFAT filesystem utilities (mkfs.exfat, exfatlabel)

    # Network and file
    lftp # FTP/SFTP/FTPS client with scripting support (works headless and on servers)
    wget # HTTP/HTTPS/FTP file retrieval
    unzip # ZIP archive extraction
    tcpdump # network sniffer
    ethtool # NIC driver, offload, EEE and counter inspection (ethtool -i/-k/-S)
    ncurses # Free software emulation of curses in SVR4 and more
    nmap # Free and open source utility for network discovery and security auditing
    wl-clipboard # Command-line copy/paste utilities for Wayland

    # Tools
    gnumake # Tool to control the generation of non-source files from sources
    curl # Command line tool for transferring files with URL syntax
    ripgrep # Utility that combines the usability of The Silver Searcher with the raw speed of grep
    imagemagick # Software suite to create, edit, compose, or convert bitmap images (identify, convert, etc.)
    ffmpeg # Audio/video processing (ffmpeg, ffprobe for codec/duration/fps inspection)
    yt-dlp # Media downloader CLI; pairs naturally with ffmpeg for merge/conversion tasks
    tree # Directory tree viewer
    poppler-utils # PDF utilities (pdfinfo, pdftotext, etc.)
    qpdf # PDF transformation and inspection tool

    # icons (minimal for CLI apps that might need them)
    hicolor-icon-theme # Default fallback theme used by implementations of the icon theme specification
    adwaita-icon-theme
  ];
}
