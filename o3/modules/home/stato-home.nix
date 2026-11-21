# modules/home/stato-home.nix
# Fact of the active home: the locked revisions of the flake inputs it was
# built from, in ~/.local/state/nixos/home.json. A switch changes the file
# together with the generation, by whoever runs it (the agent with remoto
# allinea, or the custodian by hand), so `remoto stato` reads which ai,
# home-manager and nixpkgs every host runs instead of inferring it from
# dates; /manutenzione certifies applicato_su from it.
{
  inputs,
  config,
  lib,
  ...
}: let
  # Version of a package only where this home installs it.
  installato = nome:
    lib.findFirst (v: v != null) null
    (map (p:
      if (p.pname or "") == nome
      then p.version or null
      else null)
    config.home.packages);
in {
  home.file.".local/state/nixos/home.json".text = builtins.toJSON {
    input = lib.mapAttrs (_: i: i.rev or null) (removeAttrs inputs ["self" "identity"]);
    gogcli = installato "gogcli";
  };
}
