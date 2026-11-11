# modules/home/cicli.nix
#
# Mechanism of the autonomous cycle: one user unit ciclo-<repo> for
# every repo that ../../cicli.nix assigns to this host, plus its timer only
# in state "timer". User units, not system ones: lingering is already on
# where the pilots run (deck), the change stays home-level, and
# the unit finds Claude's credentials (~/.claude/.credentials.json) and the
# passphrase-less ssh key in the home, with BatchMode and no agent.
#
# The unit is the real fence: read-only home, writable only the checkout,
# the state directory, Claude's state and the paths the repo declares. A
# repo whose round runs home-manager switch declares homeWritable, and its
# fence is then the harness permissions alone (nixos, custodian 2026-10-16).
# ciclo-avvio checks lock, branch, clean tree and divergence from origin
# before Claude, and stops without merge, rebase or stash; it never commits
# nor pushes, the round does. ciclo-chiusura runs as ExecStopPost, after a
# timeout or a kill too, and appends the outcome to
# ~/.local/state/ciclo/<repo>/tentativi.jsonl, or to the checkout folder the
# repo declares as giri (ciclo-avvio says when); when the namespace itself
# fails, ciclo-namespace writes it from outside, always in the state.
#
# A repo with lanciatore = true (method, 2026-11-08) runs instead method's
# canonical launcher, o3/lanciatore.py of the canon checkout: the outer unit
# has no namespace, the launcher does sessions, lock, pull, traces and the
# closing line, and puts only the agent in the fence, a transient unit
# ciclo-<repo>-agente started with systemd-run. The fence is the same one,
# plus what git runs from the launcher (registry.nix). BindsTo and After
# tie the agent to the outer unit, --expand-environment=no keeps the prompt
# as written, and --recinto-ferma lets the launcher stop the agent's unit
# and wait for it before the closing line (method 477b442; trials of the
# nixos home session, 2026-11-08).
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

  local = lib.filterAttrs (_: d: d.state != "esterno" && d.host == hostname) registry;

  runtimeInputs = [pkgs.coreutils pkgs.findutils pkgs.git pkgs.gnugrep pkgs.jq pkgs.openssh pkgs.util-linux];
  avvio = pkgs.writeShellApplication {
    name = "ciclo-avvio";
    inherit runtimeInputs;
    # jq filters take $variables inside single quotes on purpose.
    excludeShellChecks = ["SC2016"];
    text = builtins.readFile ./ciclo/ciclo-avvio.sh;
  };
  concorrenti = pkgs.writeShellApplication {
    name = "ciclo-concorrenti";
    runtimeInputs = runtimeInputs ++ [pkgs.python3];
    text = builtins.readFile ./ciclo/ciclo-concorrenti.sh;
  };
  fetch = pkgs.writeShellApplication {
    name = "ciclo-fetch";
    inherit runtimeInputs;
    text = builtins.readFile ./ciclo/ciclo-fetch.sh;
  };
  namespace = pkgs.writeShellApplication {
    name = "ciclo-namespace";
    inherit runtimeInputs;
    text = builtins.readFile ./ciclo/ciclo-namespace.sh;
  };
  recintoCheck = pkgs.writeShellApplication {
    name = "ciclo-recinto";
    inherit runtimeInputs;
    text = builtins.readFile ./ciclo/ciclo-recinto.sh;
  };
  sondaLanciatore = pkgs.writeShellApplication {
    name = "ciclo-sonda-lanciatore";
    inherit runtimeInputs;
    text = builtins.readFile ./ciclo/ciclo-sonda-lanciatore.sh;
  };
  chiusura = pkgs.writeShellApplication {
    name = "ciclo-chiusura";
    inherit runtimeInputs;
    # jq filters take $variables inside single quotes on purpose.
    excludeShellChecks = ["SC2016"];
    text = builtins.readFile ./ciclo/ciclo-chiusura.sh;
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

  # Host-wide settings of every round, merged over the repo's settings file
  # (host wins): --setting-sources project skips ~/.claude/settings.json,
  # so claude-code.nix does not reach the round. The PreToolUse hook blocks
  # the round's git commit when another session worked in the checkout
  # during the round (ciclo-concorrenti): sessions are checked at commit
  # time, not before the round, so an idle open session never stops it.
  hostSettings = {
    attribution = {
      commit = "";
      pr = "";
    };
    hooks.PreToolUse = [
      {
        matcher = "Bash";
        hooks = [
          {
            type = "command";
            command = "${concorrenti}/bin/ciclo-concorrenti";
          }
        ];
      }
    ];
  };

  # Private rclone mounts (rclone.nix) stay out of every round: their mount
  # point and their own config directory are inaccessible, on top of what
  # the repo declares (custodian, 2026-11-07: familiare's Drive on deck).
  privatePaths = lib.concatLists (lib.mapAttrsToList (name: m:
    lib.optionals m.private [m.mountPoint ".config/rclone-${name}"])
  config.services.rcloneMount.mounts);
  inaccessible = d: d.inaccessiblePaths ++ privatePaths;

  claude = "${pkgs-ai.claude-code}/bin/claude";
  python = "${pkgs.python3}/bin/python3";

  cfgFile = repo: d:
    pkgs.writeText "ciclo-${repo}.json" (builtins.toJSON ({
        inherit repo claude;
        inherit (d) host checkout branch settings prompt giri readWritePaths readOnlyPaths homeWritable fetch;
        maxBudgetUsd = d.maxBudgetUsd or null;
        inaccessiblePaths = inaccessible d;
        inherit hostSettings;
      }
      // lib.optionalAttrs d.lanciatore {
        inherit python;
        lanciatore = lanciatorePy d;
        sondaRecinto =
          recinto repo d {
            unit = "ciclo-${repo}-sonda-recinto";
            owner = "ciclo-${repo}-sonda.service";
            runtime = "1min";
          }
          ++ ["${recintoCheck}/bin/ciclo-recinto" "${attese repo d}"];
      }));

  # Seconds of git fetch per declared checkout. The start timeout of the unit
  # covers the ExecStartPre too, so it grows with the fetch list: a hung
  # remote costs its own budget and never fails the start.
  fetchTimeout = 15;
  startTimeout = d: 90 + fetchTimeout * builtins.length d.fetch;

  # Relative to the home, or absolute for a path outside it (/srv/bi). An
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
    # --setting-sources project skips ~/.claude/settings.json and its env;
    # its attribution reaches the round as hostSettings, merged by ciclo-avvio.
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

  service = repo: d: {
    Unit = {
      Description = "Ciclo autonomo di ${repo}: eval, exec, commit senza custode";
      ConditionPathIsDirectory = "%h/${d.checkout}/.git";
      # A home-manager switch, by the custodian or by a round, changes every
      # ciclo unit when claude-code moves (cfgFile carries its path):
      # sd-switch must not restart a round already running.
      X-RestartIfChanged = false;
    };
    Service =
      {
        # exec, not oneshot: RuntimeMaxSec has no effect on oneshot units.
        Type = "exec";
        RuntimeMaxSec = d.maxRuntime;
        TimeoutStopSec = "30s";
        WorkingDirectory = "%h/${d.checkout}";
        StateDirectory = "ciclo/${repo}";
        # "+": outside the namespace, where the .git/ of the declared
        # checkouts is writable. Open sessions are no longer checked here:
        # ciclo-concorrenti does it at commit time.
        ExecStartPre = lib.optional (d.fetch != []) "+${fetch}/bin/ciclo-fetch ${cfgFile repo d} ${toString fetchTimeout}";
        TimeoutStartSec = "${toString (startTimeout d)}s";
        ExecStart = "${avvio}/bin/ciclo-avvio ${cfgFile repo d}";
        # "+" only for the namespace failure, where ciclo-chiusura cannot run;
        # ciclo-chiusura stays fenced, since it runs git in the checkout.
        ExecStopPost = [
          "+${namespace}/bin/ciclo-namespace ${cfgFile repo d}"
          "${chiusura}/bin/ciclo-chiusura ${cfgFile repo d}"
        ];
        StandardInput = "null";
        Environment = unitEnvironment repo d;
        NoNewPrivileges = true;
      }
      // fence unitRoots repo d;
  };

  # --- Canonical launcher (lanciatore = true) ---

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
        --recinto ${lib.escapeShellArg (lib.escapeShellArgs (recinto repo d {
        unit = agentUnit repo;
        owner = "ciclo-${repo}.service";
        runtime = d.agentMaxRuntime;
      }))} \
        --recinto-ferma ${lib.escapeShellArg "${systemctl} --user stop ${agentUnit repo}"}
    '';

  # Outside the fence: the launcher needs git and ssh for fetch and pull.
  outerEnvironment = repo: d: let
    e = unitEnvironment repo d;
  in
    ["PATH=${lib.makeBinPath [pkgs.git pkgs.openssh]}:${lib.removePrefix "PATH=" (lib.head e)}"] ++ lib.tail e;

  serviceLanciatore = repo: d: {
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
  probeLanciatore = repo: d: {
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

  # The probe is the same unit, fence included, in probe mode: read-only
  # checks and fence tests, never Claude, no closing line among the attempts.
  # No session check: sessions matter only at the round's commit.
  probe = repo: d: let
    s = service repo d;
  in {
    Unit = s.Unit // {Description = "Sonda del ciclo autonomo di ${repo}: controlli e recinto, senza Claude";};
    Service =
      # The probe never fetches.
      removeAttrs s.Service ["ExecStopPost" "ExecStartPre"]
      // {
        RuntimeMaxSec = "2min";
        Environment = s.Service.Environment ++ ["CICLO_SONDA=1"];
      };
  };
in {
  assertions =
    lib.mapAttrsToList (repo: d: {
      assertion = lib.elem d.state ["manuale" "timer" "esterno"] && (d.state == "esterno" || d.host != null);
      message = "cicli.nix: ${repo} vuole state manuale|timer|esterno e host non nullo fuori da esterno";
    })
    registry
    ++ lib.mapAttrsToList (repo: d: {
      assertion = !d.lanciatore || d.agentMaxRuntime != null;
      message = "cicli.nix: ${repo} usa il lanciatore e vuole agentMaxRuntime, sotto maxRuntime";
    })
    local
    ++ lib.mapAttrsToList (repo: _: {
      assertion = !(hasView repo) || viewHere repo;
      message = "cicli.nix: il ciclo autonomo di ${repo} gira su ${hostname}, che non ne serve la vista: ciclo autonomo e vista dello stesso repo stanno sullo stesso host";
    })
    local;

  # The full picture, for the home to compute missed starts against cadence.
  home.file.".local/state/ciclo/decisioni.json".text = builtins.toJSON (import ../../cicli.nix {inherit identity;});

  systemd.user.services =
    lib.mapAttrs' (repo: d:
      lib.nameValuePair "ciclo-${repo}" (
        if d.lanciatore
        then serviceLanciatore repo d
        else service repo d
      ))
    local
    // lib.mapAttrs' (repo: d:
      lib.nameValuePair "ciclo-${repo}-sonda" (
        if d.lanciatore
        then probeLanciatore repo d
        else probe repo d
      ))
    local;

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
