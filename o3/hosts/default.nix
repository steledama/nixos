# o3/hosts/default.nix
{
  config,
  pkgs,
  lib,
  self,
  identity,
  ...
}: {
  # Il flake senza override valuta i template pubblici (nix flake check), ma
  # non deve mai attivarli: con chiavi e indirizzi segnaposto un host reale
  # resterebbe senza accesso SSH. Il controllo è una derivazione che fallisce
  # in build, non un'assertion, perché la valutazione dei template deve
  # passare; e non un preSwitchCheck, che scatta quando nixos-rebuild ha già
  # registrato la generazione nel profilo. Con l'identità locale non esiste e
  # il toplevel non cambia.
  system.checks = lib.optional (identity.template or false) (
    pkgs.runCommand "identita-reale" {} ''
      echo "Identità di esempio: questa configurazione usa i template pubblici di o3/identity." >&2
      echo "Costruire e attivare con o3/scripts/con-identita.sh (o3/identity/README.md)." >&2
      exit 1
    ''
  );

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
    linger = true;
    openssh.authorizedKeys.keys = lib.attrValues identity.home."${config.networking.hostName}AuthorizedKeys";
  };
  services.niriDesktop.autoLoginUser = "stele";

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

  # Base di soccorso (kb/configuration-patterns.md): git ed editor usabili da
  # TTY e da root anche quando la home non si attiva. nano resta l'editor di
  # default di NixOS; helix è lo stesso store path della home (pin comune).
  programs.git.enable = true;

  # Common system packages: diagnosi, hardware e soccorso, usati anche da
  # root (kb/configuration-patterns.md). Gli strumenti dell'utente vivono a
  # home (modules/home/shell.nix, modules/home/dev-tools.nix); coreutils,
  # findutils, which, ncurses e curl arrivano già dalla base di NixOS.
  environment.systemPackages = with pkgs; [
    helix # Editor di soccorso, cfr. programs.git sopra
    # System monitoring and diagnostics
    dmidecode # Hardware information from BIOS/UEFI (motherboard, CPU, RAM slots)
    hdparm # Disk performance benchmarking and drive parameter control (SATA)
    nvme-cli # NVMe drive info and management (nvme id-ctrl, smart-log)
    iotop # I/O usage monitoring
    lm_sensors # Hardware sensors reading
    lsof # Tool to list open files
    pciutils # Tools for inspecting PCI devices (includes lspci)
    usbutils # Tools for inspecting USB devices (includes lsusb)

    # System management and utilities
    efibootmgr # EFI Boot Manager utility
    file # Identify file types by content (magic bytes)
    psmisc # Set of small useful utilities that use the proc filesystem (killall)
    parted # Disk partitioning utility (includes partprobe)
    exfatprogs # exFAT filesystem utilities (mkfs.exfat, exfatlabel)

    # Network and file
    wget # HTTP/HTTPS/FTP file retrieval
    unzip # ZIP archive extraction
    tcpdump # network sniffer
    ethtool # NIC driver, offload, EEE and counter inspection (ethtool -i/-k/-S)
    nmap # Free and open source utility for network discovery and security auditing

    # Fallback icon theme for the system-level apps (foot)
    hicolor-icon-theme # Default fallback theme used by implementations of the icon theme specification
  ];
}
