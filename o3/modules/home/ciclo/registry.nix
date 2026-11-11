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
  # With the canonical launcher, minutes and budget are the repo's policy, in
  # its o3/ciclo/lanciatore.toml (method o3/motori-del-ciclo.md): the host
  # keeps no value per repo, only one physical parachute above any profile,
  # the same for all. The agent's unit ends first, so the launcher still
  # writes the closing line. A profile above 80 minutes needs these raised.
  paracadute = {
    esterno = "90min";
    agente = "85min";
  };
in
  lib.mapAttrs (repo: entry:
    if entry.state == "esterno"
    then entry
    else let
      d = defaults // entry;
    in
      lib.throwIf ((entry.lanciatore or false) && (entry ? maxRuntime || entry ? agentMaxRuntime || entry ? maxBudgetUsd))
      "cicli.nix: ${repo} usa il lanciatore: minuti e budget stanno nel suo o3/ciclo/lanciatore.toml, non nel registro"
      d
      // lib.optionalAttrs d.lanciatore {
        maxRuntime = paracadute.esterno;
        agentMaxRuntime = paracadute.agente;
      }
      // {
        # Protect the cycle's own instructions even with a writable home. With
        # the canonical launcher, also what git runs from the launcher outside
        # the fence: the round never writes them (method o3/lanciatore.py).
        readOnlyPaths = lib.unique (d.readOnlyPaths
          ++ ["${d.checkout}/o3/ciclo"]
          ++ lib.optionals d.lanciatore [
            "${d.canone}/o3/lanciatore.py"
            # Canonical protected path from method de73101: a round that
            # changed it would weaken the policy of the next ones.
            "${d.canone}/o3/esecutore_codex.py"
            "${d.checkout}/.git/config"
            "${d.checkout}/.git/hooks"
            "${d.checkout}/.git/lanciatore"
          ]);
      })
  registry
