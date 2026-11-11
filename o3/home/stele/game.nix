# home/stele/game.nix
# stele@game: ciò che game ha in più della baseline o3/home/default.nix.
{...}: {
  imports = [
    ../default.nix
    ../../modules/home/ssh-github-familiare.nix
    ../../modules/home/steam-pipewire-wrapper.nix
    ../../modules/home/game-audio-rec.nix
  ];

  home.stateVersion = "25.11";
}
