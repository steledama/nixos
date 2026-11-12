# modules/home/cicli.nix
#
# Mechanism of the autonomous cycle: one user unit ciclo-<repo> for
# every repo that ../../cicli.nix assigns to this host, plus its timer only
# in state "timer". User units, not system ones: lingering is already on
# where the pilots run (deck), the change stays home-level, and
# the unit finds Claude's credentials (~/.claude/.credentials.json) and the
# passphrase-less ssh key in the home, with BatchMode and no agent.
#
# Every cycle runs method's canonical launcher, o3/lanciatore.py of the
# canon checkout (method from 2026-11-08, the others from 2026-11-11): the
# outer unit has no namespace, the launcher does sessions, lock, pull,
# traces and the closing line, and puts only the agent in the fence, a
# transient unit ciclo-<repo>-agente started with systemd-run. The fence:
# read-only home, writable only the checkout, the state directory, Claude's
# and Codex's state and the paths the repo declares, plus what git runs
# from the launcher read-only (registry.nix). A repo whose round runs
# home-manager switch declares homeWritable, and its fence is then the
# harness permissions alone (nixos, custodian 2026-10-16). BindsTo and After
# tie the agent to the outer unit, --expand-environment=no keeps the prompt
# as written, and --recinto-ferma lets the launcher stop the agent's unit
# and wait for it before the closing line (method 477b442). From method
# accb3b5 the stop runs after every agent and a nonzero exit is code 25
# with a persistent fermo, so it is ciclo-recinto-ferma, which verifies the
# unit and its cgroup are gone instead of failing on a unit --collect
# already unloaded.
{
  config,
  lib,
  pkgs,
  pkgs-ai,
  hostname,
  identity,
  ...
}: let
  registry = import ./ciclo/registry.nix {inherit lib identity;};
  presentations = import ../../presentations.nix;
  # The view shows the autonomous cycle by reading its state on this host
  # (presentations.nix module): a repo with a permanent view must be served
  # by the host that runs its autonomous cycle.
  served = lib.attrByPath ["services" "projectPresentations"] {enable = false;} config;
  hasView = repo: lib.any (entry: entry ? ${repo}) (lib.attrValues presentations.privileged);
  viewHere = repo: served.enable && presentations.privileged.${served.privilegedAs} ? ${repo};

  local = lib.filterAttrs (_: d: d.host == hostname) registry;

  runtimeInputs = [pkgs.coreutils pkgs.findutils pkgs.git pkgs.gnugrep pkgs.jq pkgs.openssh pkgs.util-linux];
  fetch = pkgs.writeShellApplication {
    name = "ciclo-fetch";
    inherit runtimeInputs;
    text = builtins.readFile ./ciclo/ciclo-fetch.sh;
  };
  recintoCheck = pkgs.writeShellApplication {
    name = "ciclo-recinto";
    inherit runtimeInputs;
    text = builtins.readFile ./ciclo/ciclo-recinto.sh;
  };
  recintoFerma = pkgs.writeShellApplication {
    name = "ciclo-recinto-ferma";
    inherit runtimeInputs;
    text = builtins.readFile ./ciclo/ciclo-recinto-ferma.sh;
  };
  sondaLanciatore = pkgs.writeShellApplication {
    name = "ciclo-sonda-lanciatore";
    inherit runtimeInputs;
    text = builtins.readFile ./ciclo/ciclo-sonda-lanciatore.sh;
  };

  # A wrapper resolves the real command in the PATH that follows its own
  # directory, then prepends the declared arguments. It stops aliases and
  # unaware calls, not a call by the absolute path of the real binary.
  wrapperBin = repo: d:
    pkgs.symlinkJoin {
      name = "ciclo-${repo}-comandi";
      paths = lib.mapAttrsToList (cmd: args:
        pkgs.writeShellScriptBin cmd ''
          self=$(cd "$(dirname "$0")" && pwd)
          rest=$(printf '%s' "$PATH" | tr ':' '\n' | grep -vxF "$self" | paste -sd:)
          real=$(PATH="$rest" command -v ${cmd}) || { echo "ciclo: ${cmd} non trovato" >&2; exit 127; }
          exec "$real" ${lib.escapeShellArgs args} "$@"
        '')
      d.wrappers;
    };

  # Private rclone mounts (rclone.nix) stay out of every round: their mount
  # point and their own config directory are inaccessible, on top of what
  # the repo declares (custodian, 2026-11-07: familiare's Drive on deck).
  privatePaths = lib.concatLists (lib.mapAttrsToList (name: m:
    lib.optionals m.private [m.mountPoint ".config/rclone-${name}"])
  config.services.rcloneMount.mounts);
  inaccessible = d: d.inaccessiblePaths ++ privatePaths;

  claude = "${pkgs-ai.claude-code}/bin/claude";
  codex = "${pkgs-ai.codex}/bin/codex";
  python = "${pkgs.python3}/bin/python3";

  # What ciclo-fetch and ciclo-sonda-lanciatore read.
  cfgFile = repo: d:
    pkgs.writeText "ciclo-${repo}.json" (builtins.toJSON {
      inherit repo python;
      inherit (d) fetch;
      lanciatore = lanciatorePy d;
      sondaRecinto =
        recinto repo d {
          unit = "ciclo-${repo}-sonda-recinto";
          owner = "ciclo-${repo}-sonda.service";
          runtime = "1min";
        }
        ++ ["${recintoCheck}/bin/ciclo-recinto" "${attese repo d}"];
    });

  # Seconds of git fetch per declared checkout. The start timeout of the unit
  # covers the ExecStartPre too, so it grows with the fetch list: a hung
  # remote costs its own budget and never fails the start.
  fetchTimeout = 15;
  startTimeout = d: 90 + fetchTimeout * builtins.length d.fetch;

  # Relative to the home, or absolute for a path outside it. An
  # absolute one comes from a system module, and a home switch may land
  # before its rebuild: "-" keeps the namespace up, the probe still checks it.
  inHome = r: paths:
    map (p:
      if lib.hasPrefix "/" p
      then "-${p}"
      else "${r.h}/${p}")
    paths;
  # A read-only path inside the checkout may not exist yet: it arrives with
  # the pull of the round that first brings it, and "-" keeps the namespace up.
  inCheckout = d: p: lib.hasPrefix "${d.checkout}/" p;
  readOnlyIn = r: d: map (p: lib.optionalString (inCheckout d p) "-" + "${r.h}/${p}") d.readOnlyPaths;

  # Roots of paths and environment: specifiers in a unit file, literal paths
  # in the properties of a transient unit, passed by systemd-run as written.
  unitRoots = {
    h = "%h";
    s = "%S";
    u = "%u";
  };
  literalRoots = {
    h = config.home.homeDirectory;
    s = config.xdg.stateHome;
    u = config.home.username;
  };

  # The fence of the round: read-only home, writable only the checkout, the
  # state directory, Claude's state and the paths the repo declares.
  fence = r: repo: d: {
    # homeWritable: the round runs home-manager switch, which relinks files
    # all over the home; the fence is then the harness permissions alone.
    ReadOnlyPaths = lib.optional (!d.homeWritable) r.h ++ readOnlyIn r d;
    ReadWritePaths =
      ["${r.h}/${d.checkout}" "${r.s}/ciclo/${repo}" "${r.h}/.claude" "-${r.h}/.claude.json"]
      # Codex, when the repo's profile names it among motori: sessions,
      # auth.json refresh and its state live in CODEX_HOME (method
      # o3/motori-del-ciclo.md).
      ++ ["-${r.h}/.codex"]
      ++ inHome r d.readWritePaths;
    # "-": a private path may not exist yet (account not authorized on
    # this host); the probe still checks it is unreadable.
    InaccessiblePaths = map (p: "-${lib.removePrefix "-" p}") (inHome r (inaccessible d));
  };

  environment = r: repo: d: [
    {
      name = "PATH";
      value = "${lib.optionalString (d.wrappers != {}) "${wrapperBin repo d}/bin:"}${r.h}/.nix-profile/bin:/etc/profiles/per-user/${r.u}/bin:/run/current-system/sw/bin";
    }
    {
      name = "GIT_TERMINAL_PROMPT";
      value = "0";
    }
    {
      name = "GIT_SSH_COMMAND";
      value = "ssh -o BatchMode=yes";
    }
    {
      name = "PAGER";
      value = "cat";
    }
    {
      name = "DISABLE_AUTOUPDATER";
      value = "1";
    }
    {
      name = "CLAUDE_CODE_DISABLE_AUTO_MEMORY";
      value = "1";
    }
  ];
  unitEnvironment = repo: d:
    map (e:
      if lib.hasInfix " " e.value
      then "\"${e.name}=${e.value}\""
      else "${e.name}=${e.value}")
    (environment unitRoots repo d);

  # The launcher comes from the live canon checkout, as the gate does, and
  # pulls it at start (method's decision of 2026-11-08: no pinned version).
  lanciatorePy = d: "${config.home.homeDirectory}/${d.canone}/o3/lanciatore.py";
  agentUnit = repo: "ciclo-${repo}-agente";
  # systemd-run and systemctl of the running system, matching its manager.
  systemdRun = "/run/current-system/sw/bin/systemd-run";
  systemctl = "/run/current-system/sw/bin/systemctl";

  # The command the launcher puts before the agent (--recinto): a transient
  # unit with the round's fence and environment, tied to its owner unit so
  # it cannot outlive it. The launcher reads it with shlex, hence the quoting.
  recinto = repo: d: {
    unit,
    owner,
    runtime,
  }: let
    f = fence literalRoots repo d;
  in
    [
      systemdRun
      "--user"
      "--wait"
      "--pipe"
      "--quiet"
      "--collect"
      # Explicit, since ciclo-recinto-ferma looks for the cgroup there.
      "--slice=app.slice"
      "--same-dir"
      "--expand-environment=no"
      "--service-type=exec"
      "--unit=${unit}"
      # Without it systemd-run describes the unit with its whole command line,
      # and the round's prompt ends up in the journal at every start.
      "--description=Recinto del ciclo autonomo di ${repo}"
    ]
    ++ map (e: "--setenv=${e.name}=${e.value}") (environment literalRoots repo d)
    ++ map (p: "--property=${p}") (
      [
        "NoNewPrivileges=yes"
        "RuntimeMaxSec=${runtime}"
        "TimeoutStopSec=30s"
        "BindsTo=${owner}"
        "After=${owner}"
      ]
      ++ map (x: "ReadOnlyPaths=${x}") f.ReadOnlyPaths
      ++ map (x: "ReadWritePaths=${x}") f.ReadWritePaths
      ++ map (x: "InaccessiblePaths=${x}") f.InaccessiblePaths
    );

  # What the probe expects of each fence path, tested from inside it.
  attese = repo: d: let
    h = config.home.homeDirectory;
    abs = p:
      if lib.hasPrefix "/" p
      then p
      else "${h}/${p}";
    voce = atteso: opzionale: p: {
      path = abs (lib.removePrefix "-" p);
      inherit atteso opzionale;
    };
  in
    pkgs.writeText "ciclo-${repo}-attese.json" (builtins.toJSON (
      [
        (voce (
            if d.homeWritable
            then "scrivibile"
            else "sola-lettura"
          )
          false
          h)
        (voce "scrivibile" false d.checkout)
        (voce "scrivibile" false "${config.xdg.stateHome}/ciclo/${repo}")
      ]
      ++ map (voce "scrivibile" false) d.readWritePaths
      ++ map (p: voce "sola-lettura" (inCheckout d p) p) d.readOnlyPaths
      ++ map (voce "inaccessibile" false) (inaccessible d)
    ));

  # ExecStart of the outer unit: a script, so that the --recinto string
  # reaches the launcher intact, without systemd's own quoting and $ rules.
  lancia = repo: d:
    pkgs.writeShellScript "ciclo-${repo}-lanciatore" ''
      exec ${python} ${lib.escapeShellArg (lanciatorePy d)} \
        --claude ${claude} \
        --codex ${codex} \
        --recinto ${lib.escapeShellArg (lib.escapeShellArgs (recinto repo d {
        unit = agentUnit repo;
        owner = "ciclo-${repo}.service";
        runtime = d.agentMaxRuntime;
      }))} \
        --recinto-ferma ${lib.escapeShellArg (lib.escapeShellArgs ["${recintoFerma}/bin/ciclo-recinto-ferma" systemctl "${agentUnit repo}.service"])}
    '';

  # Outside the fence: the launcher needs git and ssh for fetch and pull.
  outerEnvironment = repo: d: let
    e = unitEnvironment repo d;
  in
    ["PATH=${lib.makeBinPath [pkgs.git pkgs.openssh]}:${lib.removePrefix "PATH=" (lib.head e)}"] ++ lib.tail e;

  service = repo: d: {
    Unit = {
      Description = "Ciclo autonomo di ${repo}: lanciatore canonico, agente nel recinto";
      ConditionPathIsDirectory = "%h/${d.checkout}/.git";
      X-RestartIfChanged = false;
    };
    Service = {
      Type = "exec";
      RuntimeMaxSec = d.maxRuntime;
      # More than the agent's 30s: on SIGTERM to this unit the launcher stops
      # the agent's unit, waits for it, then writes net and closing line
      # (method 7a8d57e). At 30s an agent ignoring SIGTERM took the launcher
      # down with it, before the closing line.
      TimeoutStopSec = "90s";
      WorkingDirectory = "%h/${d.checkout}";
      # fetch.json and sonde.jsonl; the launcher keeps lock and merged
      # settings in .git/lanciatore, its traces in i1/giri.
      StateDirectory = "ciclo/${repo}";
      # No namespace here: ciclo-fetch writes the .git/ of the declared
      # checkouts directly, before the launcher's own session check.
      ExecStartPre = lib.optional (d.fetch != []) "${fetch}/bin/ciclo-fetch ${cfgFile repo d} ${toString fetchTimeout}";
      TimeoutStartSec = "${toString (startTimeout d)}s";
      ExecStart = "${lancia repo d}";
      StandardInput = "null";
      Environment = outerEnvironment repo d;
      NoNewPrivileges = true;
    };
  };

  # The probe of a launcher cycle: lanciatore.py --controlli, then the fence
  # tested from inside a transient unit like the agent's (ciclo-sonda-lanciatore).
  probe = repo: d: {
    Unit = {
      Description = "Sonda del ciclo autonomo di ${repo}: controlli del lanciatore e recinto, senza Claude";
      ConditionPathIsDirectory = "%h/${d.checkout}/.git";
      X-RestartIfChanged = false;
    };
    Service = {
      Type = "exec";
      RuntimeMaxSec = "3min";
      TimeoutStopSec = "30s";
      WorkingDirectory = "%h/${d.checkout}";
      StateDirectory = "ciclo/${repo}";
      ExecStart = "${sondaLanciatore}/bin/ciclo-sonda-lanciatore ${cfgFile repo d}";
      StandardInput = "null";
      Environment = outerEnvironment repo d;
      NoNewPrivileges = true;
    };
  };
in {
  assertions =
    lib.mapAttrsToList (repo: d: {
      assertion = lib.elem d.state ["manuale" "timer"];
      message = "cicli.nix: ${repo} vuole state manuale|timer";
    })
    registry
    ++ lib.mapAttrsToList (repo: _: {
      assertion = !(hasView repo) || viewHere repo;
      message = "cicli.nix: il ciclo autonomo di ${repo} gira su ${hostname}, che non ne serve la vista: ciclo autonomo e vista dello stesso repo stanno sullo stesso host";
    })
    local;

  # The full picture, for the home to compute missed starts against cadence.
  # Cycles on deck carry the parachute as maxRuntime: the view's late-close
  # limit, since their minutes live in the repo's profile.
  home.file.".local/state/ciclo/decisioni.json".text = builtins.toJSON (lib.mapAttrs (repo: e: e // {inherit (registry.${repo}) maxRuntime;}) (import ../../cicli.nix {inherit identity;}));

  systemd.user.services =
    lib.mapAttrs' (repo: d: lib.nameValuePair "ciclo-${repo}" (service repo d)) local
    // lib.mapAttrs' (repo: d: lib.nameValuePair "ciclo-${repo}-sonda" (probe repo d)) local;

  systemd.user.timers = lib.mapAttrs' (repo: d:
    lib.nameValuePair "ciclo-${repo}" {
      Unit.Description = "Cadenza del ciclo autonomo di ${repo}";
      # A missed start is not recovered: the home sees it against cadence.
      # Powered off at the scheduled time: no start at boot, and after one
      # hour the home turns it red, which is true. Suspended: systemd fires
      # the elapsed timer on resume, Persistent or not, and that late start
      # clears the red.
      Timer = {
        OnCalendar = "${d.cadence} ${d.time}";
        Persistent = false;
      };
      Install.WantedBy = ["timers.target"];
    })
  (lib.filterAttrs (_: d: d.state == "timer") local);
}
