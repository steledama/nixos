# Shared interpretation of the cycle registry for units and presentations.
# External schedulers have no checkout and do not receive NixOS defaults.
{
  lib,
  identity ? import ../../../identity,
  registry ? import ../../../cicli.nix {inherit identity;},
}: let
  defaults = {
    branch = "main";
    settings = "o3/ciclo/permessi.json";
    prompt = "o3/ciclo/prompt.md";
    giri = "i1/giri";
    readWritePaths = [];
    readOnlyPaths = [];
    inaccessiblePaths = [];
    homeWritable = false;
    wrappers = {};
    fetch = [];
    lanciatore = false;
    canone = "method";
    agentMaxRuntime = null;
  };
in
  lib.mapAttrs (_: entry:
    if entry.state == "esterno"
    then entry
    else let
      d = defaults // entry;
    in
      d
      // {
        # Protect the cycle's own instructions even with a writable home. With
        # the canonical launcher, also what git runs from the launcher outside
        # the fence: the round never writes them (method o3/lanciatore.py).
        readOnlyPaths = lib.unique (d.readOnlyPaths
          ++ ["${d.checkout}/o3/ciclo"]
          ++ lib.optionals d.lanciatore [
            "${d.canone}/o3/lanciatore.py"
            "${d.checkout}/.git/config"
            "${d.checkout}/.git/hooks"
            "${d.checkout}/.git/lanciatore"
          ]);
      })
  registry
