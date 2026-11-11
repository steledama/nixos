# home/stele/neve.nix
# Standalone home-manager configuration for stele@neve
{identity, ...}: {
  imports = [
    ../default.nix # Config di base (shell, helix, catppuccin, md2pdf)
    ../../modules/home/dev-tools.nix
    ../../modules/home/claude-code.nix
    ../../modules/home/ssh-common.nix
    ../../modules/home/ssh-home-lan.nix
    ../../modules/home/ssh-github-familiare.nix
    ../../modules/home/zed.nix
    ../../modules/home/syncthing-home-mesh.nix # Sync ~/sync con il resto della mesh casa
    ../../modules/home/niri.nix
    ../../modules/home/audio-manager.nix
    ../../modules/home/display-manager.nix
  ];

  services.syncthingHomeMesh = {
    enable = true;
    thisHost = "neve";
    syncPath = "/home/stele/sync";
  };

  # Identificazione utente
  home.username = "stele";
  home.homeDirectory = "/home/stele";

  # Git user configuration
  programs.git.settings.user = {
    name = identity.home.gitName;
    email = identity.home.email;
  };

  # Niri default session: tastiera IT, monitor layout host-specifico.
  programs.niriConfig = {
    enable = true;
    keyboardLayout = "it";
    extraConfig = ''
      spawn-at-startup "/home/stele/.nix-profile/bin/display-manager" "solo27"
    '';
  };

  home.stateVersion = "25.11";
}
