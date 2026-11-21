# modules/home/unfree.nix
# Gemello home di modules/system/unfree.nix: allowUnfree resta false, le
# eccezioni sono dichiarate in `unfree.allowedNames` dal modulo home che
# installa il pacchetto, con commento # UNFREE:. Impostare nixpkgs.config fa
# reimportare a Home Manager il nixpkgs del pin comune con questa config; gli
# overlay condivisi arrivano da mkHome in flake.nix. Mappa: kb/unfree-packages.md.
{
  config,
  lib,
  ...
}: {
  options.unfree.allowedNames = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    example = ["chromium"];
    description = "Unfree package names accepted by the home allowUnfreePredicate.";
  };

  config.nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) config.unfree.allowedNames;
}
