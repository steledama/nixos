# modules/home/presentations.nix
#
# Permanent presentation of the projects served by this host: one user unit
# presentazione-<repo> per checkout, with its own --port. Migrated repos run
# the canonical server with --root; older adopters keep their local server
# until their own migration.
# Repos and ports live in ../../presentations.nix; the firewall is system-level.
#
# Checkout form, for the repos outside registry.published: o3/view/serve.py
# serves view/ straight from the checkout. The old presentation/ form and its
# -vista units are gone (method prescription migrazione-viste).
#
# Published form (method prescription viste-fuori-da-git), for the repos in
# registry.published: view/ is no longer served from the checkout.
# presentazione-<repo>-pubblicazione (oneshot) runs build.py --publish, which
# builds HEAD from a clean commit into %S/view/<repo> and swaps the `current`
# pointer only on success; serve.py --publish-root re-reads the pointer on
# every request, so a swap needs no restart. Publishing runs at login, before
# the server starts, and after every change of HEAD (the .path unit on
# .git/logs/HEAD: commit, checkout, the manual pull), plus a 5-minute timer
# that recovers a move lost by the path unit. Never a fetch or pull.
#
# Autonomous cycle in the home (method prescription ciclo-autonomo): a published
# repo whose autonomous cycle runs on this host (../../cicli.nix) gets
# --ciclo-state %S/ciclo/<repo>, or the checkout folder it declares as giri,
# read by serve.py on every request under /_ciclo/; with giri also
# --ciclo-unita %S/ciclo/<repo>, where the view finds the decisions.
#
# Server code: the swap reloads the views, not serve.py and the local modules
# it imports. The server records the hash of the committed o3/view tree when
# it starts, together with the canonical o3/view tree
# (%S/presentazione/<repo>.serve); after every publish, a running
# server whose stamp differs is restarted. The timer bounds the delay. A
# server restarted for another reason (crash, login) still runs the files on
# disk, uncommitted edits included.
{
  config,
  lib,
  pkgs,
  hostname,
  identity,
  ...
}: let
  cfg = config.services.projectPresentations;
  registry = import ../../presentations.nix;
  repos = registry.privileged.${cfg.privilegedAs};
  isPublished = repo: lib.elem repo registry.published;
  checkoutRepos = lib.filterAttrs (repo: _: !isPublished repo) repos;
  publishedRepos = lib.filterAttrs (repo: _: isPublished repo) repos;

  # Toolchain of build.py --publish: explicit Nix versions, not the profile.
  publishPath = lib.makeBinPath [pkgs.git pkgs.pandoc pkgs.prettier pkgs.python3];
  publishRoot = repo: "%S/view/${repo}";
  publisher = repo: "presentazione-${repo}-pubblicazione.service";

  cicli = import ./ciclo/registry.nix {inherit lib identity;};
  hasCiclo = repo: cicli ? ${repo} && cicli.${repo}.host == hostname;
  # Preserve older adopters until their own /method migration.
  viewCommand = name:
    pkgs.writeShellScript "presentation-${name}" ''
      if [ -f "o3/view/${name}.py" ]; then
        exec ${pkgs.python3}/bin/python3 "o3/view/${name}.py" "$@"
      fi
      exec ${pkgs.python3}/bin/python3 "$HOME/method/o3/view/${name}.py" --root . "$@"
    '';
  serve = "${viewCommand "serve"}";
  serveArgs = repo: port: "--publish-root ${publishRoot repo} --port ${toString port}";
  serveStart = repo: port:
    "${serve} ${serveArgs repo port}"
    + lib.optionalString (hasCiclo repo) " --ciclo-state ${cicloState repo}"
    + lib.optionalString (hasCiclo repo && cicli.${repo}.giri != null) " --ciclo-unita %S/ciclo/${repo}";
  cicloState = repo: let
    d = cicli.${repo};
  in
    if d.giri != null
    then "%h/${d.checkout}/${d.giri}"
    else "%S/ciclo/${repo}";

  # Hash of the code the server runs, written at start, compared after publish.
  serveStamp = repo: "%S/presentazione/${repo}.serve";
  # The committed tree of o3/view, not the files on disk: the restart follows
  # commits like the publish does, so edits in progress never trigger it, and
  # the tree covers serve.py with its local imports (ciclo, project, sources).
  # A changed builder costs a spare restart, idempotent.
  hashServe = "${pkgs.writeShellScript "presentation-code-hash" ''
    ${pkgs.git}/bin/git rev-parse HEAD:o3/view || exit 1
    ${pkgs.git}/bin/git -C "$HOME/method" rev-parse HEAD:o3/view
  ''}";
  stampServe = repo: "${pkgs.writeShellScript "presentazione-${repo}-stamp" ''
    ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$1")"
    ${hashServe} > "$1"
  ''} ${serveStamp repo}";
  # A successful publish brings up a server skipped for lack of any valid
  # version (start is a no-op when it runs), or restarts one whose code
  # changed since it started.
  afterPublish = repo: let
    unit = "presentazione-${repo}.service";
    systemctl = "${pkgs.systemd}/bin/systemctl --user";
  in "${pkgs.writeShellScript "presentazione-${repo}-dopo" ''
    if ${systemctl} is-active --quiet ${unit} \
      && [ "$(${pkgs.coreutils}/bin/cat "$1" 2>/dev/null)" != "$(${hashServe})" ]; then
      echo "codice di o3/view cambiato: riavvio ${unit}"
      exec ${systemctl} try-restart --no-block ${unit}
    fi
    exec ${systemctl} start --no-block ${unit}
  ''} ${serveStamp repo}";

  forEach = set: suffix: f:
    lib.mapAttrs' (repo: port: lib.nameValuePair "presentazione-${repo}${suffix}" (f repo port)) set;
  forEachRepo = forEach checkoutRepos;
  forEachPublished = forEach publishedRepos;
in {
  options.services.projectPresentations = {
    enable = lib.mkEnableOption "permanent project presentations";

    privilegedAs = lib.mkOption {
      type = lib.types.enum (lib.attrNames registry.privileged);
      example = "deck";
      description = ''
        Entry of presentations.nix served by this host.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services =
      forEachRepo "" (repo: port: {
        Unit = {
          Description = "Presentazione di ${repo} sulla porta ${toString port}";
          # A missing checkout or build leaves the unit skipped, not restarting.
          ConditionPathExists = ["%h/${repo}/view/index.html"];
        };
        Service = {
          WorkingDirectory = "%h/${repo}";
          ExecStart = "${serve} --port ${toString port}";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        Install.WantedBy = ["default.target"];
      })
      // forEachPublished "" (repo: port: {
        Unit = {
          Description = "Presentazione pubblicata di ${repo} sulla porta ${toString port}";
          # Publish before serving; Wants, not Requires: a failed build still
          # lets the server start on the last good version.
          Wants = [(publisher repo)];
          After = [(publisher repo)];
          ConditionPathExists = ["%h/${repo}/o3/view/project.py"];
          # Bounds the restarts of a server that crashes for other reasons.
          StartLimitIntervalSec = 300;
          StartLimitBurst = 5;
        };
        Service = {
          WorkingDirectory = "%h/${repo}";
          # serve.py exits 3 when no valid version exists: ExecCondition skips
          # the unit (1-254) instead of failing it, with the diagnosis in the
          # journal; the first successful publish starts it.
          ExecCondition = "${serve} --publish-root ${publishRoot repo} --check";
          ExecStartPre = stampServe repo;
          ExecStart = serveStart repo port;
          Restart = "on-failure";
          RestartSec = "5s";
          # The valid version vanished while running: no restart loop.
          RestartPreventExitStatus = 3;
        };
        Install.WantedBy = ["default.target"];
      })
      // forEachPublished "-pubblicazione" (repo: _: {
        Unit = {
          Description = "Pubblicazione delle viste di ${repo} da commit pulito";
          ConditionPathExists = ["%h/${repo}/o3/view/project.py"];
        };
        Service = {
          # No RemainAfterExit: every login and every change of HEAD publishes.
          Type = "oneshot";
          WorkingDirectory = "%h/${repo}";
          Environment = "PATH=${publishPath}";
          ExecStart = "${viewCommand "build"} --publish ${publishRoot repo}";
          ExecStartPost = afterPublish repo;
          # Bounds a hung build (one takes seconds). On timeout systemd sends
          # SIGTERM: publish.py closes the round without lock or .partial and
          # the last good version stays served.
          TimeoutStartSec = "5min";
        };
        Install.WantedBy = ["default.target"];
      });

    systemd.user.paths = forEachPublished "-pubblicazione" (repo: _: {
      Unit = {
        Description = "Cambio di HEAD nel checkout di ${repo}";
      };
      # Every move of HEAD appends to its reflog. PathChanged does not see
      # changes made before activation: the login run of the service covers them.
      Path.PathChanged = ["%h/${repo}/.git/logs/HEAD" "%h/method/.git/logs/HEAD"];
      Install.WantedBy = ["default.target"];
    });

    # Periodic check beside the path unit (method kb/view.md, recovery): a
    # move of HEAD while the oneshot is closing is lost by PathChanged, and a
    # transient build error is retried. Idempotent: with HEAD already served
    # publish.py answers "già servito" without building.
    systemd.user.timers = forEachPublished "-pubblicazione" (repo: _: {
      Unit = {
        Description = "Controllo periodico della pubblicazione di ${repo}";
      };
      Timer = {
        OnStartupSec = "5min";
        OnUnitInactiveSec = "5min";
      };
      Install.WantedBy = ["timers.target"];
    });
  };
}
