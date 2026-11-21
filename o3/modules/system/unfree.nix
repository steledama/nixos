# modules/system/unfree.nix
# Policy unfree centralizzata: allowUnfree resta false, le eccezioni sono
# dichiarate esplicitamente in `unfree.allowedNames` (lista mergeable) dal
# modulo o dall'host che installa il pacchetto, con commento # UNFREE:.
# Il predicate è definito una sola volta qui. Lista corrente per host:
# kb/unfree-packages.md.
{
  config,
  lib,
  ...
}: {
  options.unfree.allowedNames = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    example = ["obsidian"];
    description = "Unfree package names accepted by allowUnfreePredicate.";
  };

  config.nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) config.unfree.allowedNames;
}
