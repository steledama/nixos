# o3/home/default.nix
{
  config,
  identity,
  hostname,
  username,
  ...
}: {
  # Baseline of every profile: the three hosts are desktops of the same user,
  # so everything they share lives here and a profile file only adds what its
  # host has more. GUI packages stay at system level
  # (o3/modules/system/gui-apps.nix); home modules carry their configuration.
  imports = [
    ../modules/home/shell.nix # Shell config + utilities (imports fish.nix, herdr.nix, yazi.nix)
    ../modules/home/helix.nix
    ../modules/home/md2pdf.nix # Script CLI: md2pdf <file.md> → PDF
    ../modules/home/git.nix # Git with init.defaultBranch = main
    ../modules/home/cicli.nix # Cicli autonomi dei repo assegnati a questo host (o3/cicli.nix)
    ../modules/home/stato-home.nix # Rev degli input della home attiva, letti da remoto stato
    ../modules/home/rclone.nix # Mount Google Drive (FUSE, streaming)
    ../modules/home/rimonta-drive.nix # rimonta-drive: stato e restart dei mount
    ../modules/home/dev-tools.nix # LSP, formatter, agenti AI
    ../modules/home/claude-code.nix
    ../modules/home/ssh-common.nix
    ../modules/home/ssh-home-lan.nix
    ../modules/home/zed.nix
    ../modules/home/syncthing-home-mesh.nix # Sync ~/sync con il resto della mesh casa
    ../modules/home/niri.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  programs.git.settings.user = {
    name = identity.home.gitName;
    email = identity.home.email;
  };

  services.syncthingHomeMesh = {
    enable = true;
    thisHost = hostname;
    syncPath = "${config.home.homeDirectory}/sync";
  };

  # Tastiera italiana di default; il profilo cambia layout e output.
  programs.niriConfig.enable = true;

  # Drive di custode e familiare montati uguali sui tre host (custode,
  # 2026-11-07). Ogni host ha un'autorizzazione propria per account: copiare
  # i token fra host causava i conflitti di rotazione del 2026-05-29.
  # familiare è private: token in ~/.config/rclone-gdrive-familiare/rclone.conf,
  # file e mount invisibili ai cicli autonomi di deck.
  services.rcloneMount = {
    enable = true;
    mounts = identity.home.rcloneMounts;
  };

  # The public repository uses a public commit identity; other repositories
  # keep the user's local default identity.
  programs.git.includes = [
    {
      condition = "gitdir:~/nixos/";
      contents.user = {
        name = "steledama";
        email = "steledama@users.noreply.github.com";
      };
    }
  ];

  # Default application associations:
  # - Browser: Chromium for HTML and URL schemes
  # - PDF: Zathura instead of Chromium
  # - Video: mpv (reliable hw/sw decoding fallback, no green screen artifacts)
  # - Images: imv instead of Chromium
  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "chromium-browser.desktop";
      "x-scheme-handler/http" = "chromium-browser.desktop";
      "x-scheme-handler/https" = "chromium-browser.desktop";
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/vnd.avi" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/svg+xml" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/tiff" = "imv.desktop";
      "image/avif" = "imv.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "abiword.desktop";
      "application/msword" = "abiword.desktop";
    };
  };

  # XDG user directories: English names, uniform across all hosts
  # Default home-manager paths are already English (Desktop, Documents, Downloads, etc.)
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = false; # Nuovo default 26.05
    projects = null; # xdg-user-dirs >= 0.19 aggiunge ~/Projects: i repo restano in ~
  };

  # Enable home-manager itself
  programs.home-manager = {
    enable = true;
  };
}
