# home/stele/neve.nix
# stele@neve: ciò che neve ha in più della baseline o3/home/default.nix.
{...}: {
  imports = [
    ../default.nix
    ../../modules/home/ssh-github-familiare.nix
    ../../modules/home/audio-manager.nix
    ../../modules/home/display-manager.nix
  ];

  # Profilo monitor predefinito all'avvio della sessione.
  programs.niriConfig.extraConfig = ''
    spawn-at-startup "/home/stele/.nix-profile/bin/display-manager" "solo27"
  '';

  home.stateVersion = "25.11";
}
