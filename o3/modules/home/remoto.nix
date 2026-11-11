# modules/home/remoto.nix
# CLI remoto: the agent's fixed acts on game and neve, from deck.
#
# Uso: remoto stato|allinea game|neve
#
# stato reads the host; allinea runs home-manager switch from deck's staged
# tree, then moves the checkout once that tree is pushed. The servers left
# this repo on 2026-11-04 and remoto refuses them. The remote commands live
# in remoto/remoto.sh and reach the PATH through Nix, so the autonomous
# round, which cannot edit this module, cannot change them either.
# Criterion: autonomy.md, kb/cicli.md § Atti remoti.
{pkgs, ...}: let
  remoto = pkgs.writeShellApplication {
    name = "remoto";
    runtimeInputs = with pkgs; [openssh git coreutils];
    text = builtins.readFile ./remoto/remoto.sh;
  };
in {
  home.packages = [remoto];
}
