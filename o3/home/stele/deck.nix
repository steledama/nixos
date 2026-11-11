# home/stele/deck.nix
# Standalone home-manager configuration for stele@deck
{identity, ...}: {
  imports = [
    ../default.nix # Config di base (shell, helix)
    ../../modules/home/dev-tools.nix
    ../../modules/home/claude-code.nix
    ../../modules/home/ssh-common.nix
    ../../modules/home/ssh-home-lan.nix
    ../../modules/home/ssh-work-lan.nix
    ../../modules/home/zed.nix
    ../../modules/home/syncthing-home-mesh.nix # Sync ~/sync con il resto della mesh casa
    ../../modules/home/niri.nix
    ../../modules/home/presentations.nix
    ../../modules/home/pressione-salute.nix
    ../../modules/home/remoto.nix # Atti fissi dell'agente su game e neve (stato, allinea)
    ../../modules/home/bitwarden-cli.nix # bw: cassaforte personale, seed dei segreti di casa
    ../../modules/home/google-workspace-cli.nix # gog: Gmail, Calendar, Drive per i cicli salute ed economia (solo deck dal 2026-11-07)
  ];

  # Presentazioni permanenti di method, nixos, salute, economia (o3/presentations.nix)
  services.projectPresentations = {
    enable = true;
    privilegedAs = "deck";
  };

  services.syncthingHomeMesh = {
    enable = true;
    thisHost = "deck";
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

  # Niri is the default desktop on deck.
  programs.niriConfig = {
    enable = true;
    keyboardLayout = "us";
    keyboardVariant = "intl";
    extraConfig = ''
      output "DSI-1" {
        mode "1200x1920"
        position x=0 y=0
        scale 1.5
      }
    '';
    internalDisplay = "DSI-1";
  };

  home.stateVersion = "23.11";
}
