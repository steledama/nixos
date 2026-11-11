# home/stele/deck.nix
# stele@deck: ciò che deck ha in più della baseline o3/home/default.nix.
{...}: {
  imports = [
    ../default.nix
    ../../modules/home/ssh-work-lan.nix
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

  programs.niriConfig = {
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
