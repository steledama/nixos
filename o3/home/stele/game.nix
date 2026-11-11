# home/stele/game.nix
# Standalone home-manager configuration for stele@game
{
  # pkgs not needed: system packages moved to hosts/default.nix
  identity,
  ...
}: {
  imports = [
    ../default.nix # Config di base (shell, helix, catppuccin)
    ../../modules/home/dev-tools.nix # Git, LSP, formatters, AI agents
    ../../modules/home/claude-code.nix # Claude Code settings
    ../../modules/home/ssh-common.nix
    ../../modules/home/ssh-home-lan.nix
    ../../modules/home/ssh-github-familiare.nix
    ../../modules/home/zed.nix
    ../../modules/home/syncthing-home-mesh.nix # Sync ~/sync con il resto della mesh casa
    ../../modules/home/niri.nix
    ../../modules/home/steam-pipewire-wrapper.nix
    ../../modules/home/game-audio-rec.nix
  ];

  services.syncthingHomeMesh = {
    enable = true;
    thisHost = "game";
    syncPath = "/home/stele/sync";
  };

  # User identification
  home.username = "stele";
  home.homeDirectory = "/home/stele";

  # Git user configuration
  programs.git.settings.user = {
    name = identity.home.gitName;
    email = identity.home.email;
  };

  programs.niriConfig = {
    enable = true;
    keyboardLayout = "it";
  };

  home.stateVersion = "25.11";
}
