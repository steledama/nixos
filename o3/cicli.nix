# cicli.nix
#
# Decisions of the autonomous cycle (method o2/dove-gira-il-ciclo-autonomo.md):
# for every repo, where and when its `eval all -> exec all -> commit` round
# runs. The mechanism lives in modules/home/cicli.nix and generates the
# units ciclo-<repo> only on the host named here: one value of `host` per
# repo, so "a single host keeps a repo's autonomous cycle" holds by construction.
#
# Boundary: nixos decides where and when, the repo decides what. Every cycle
# runs method's canonical launcher (o3/lanciatore.py of the checkout
# `canone`, default "method"; method from 2026-11-08, the others from
# 2026-11-11): branch, prompt, permissions, time cap, budget and engines
# (motori) are the repo's, in o3/ciclo/ (lanciatore.toml, prompt.md,
# permessi.json), and the registry holds none of them. The outer unit has
# no namespace; the agent alone runs in the fence, a transient unit
# ciclo-<repo>-agente; both carry the single parachute of
# modules/home/ciclo/registry.nix. The unit passes --claude and --codex:
# the repo's profile decides whether Codex ever runs.
#
# Fields:
# - host: networking hostName of the only host that runs the autonomous cycle
#   (null only for state "esterno");
# - checkout: path of the checkout relative to the home;
# - cadence + time: OnCalendar of the timer, "<cadence> <time>";
# - state: "manuale" (unit present, started only by hand with systemctl
#   --user start), "timer" (scheduled), "esterno" (outside nixos, no unit);
# - giri: folder of the checkout, ignored by git, where the launcher writes
#   tentativi.jsonl, ultimo.json and giri/<id>.jsonl; default i1/giri,
#   read by the view (presentations.nix through modules/home/ciclo/registry.nix);
# - readWritePaths, readOnlyPaths, inaccessiblePaths: fence of the unit,
#   relative to the home or absolute (readWritePaths and inaccessiblePaths),
#   on top of a read-only home; a readOnlyPaths entry
#   inside the checkout may be missing (it arrives with a pull). The module
#   always adds <checkout>/o3/ciclo to readOnlyPaths;
# - homeWritable: the home is writable, for a round that runs home-manager
#   switch; the harness permissions are then the only fence;
# - wrappers: command -> arguments always prepended, first in the unit PATH.
# - fetch: checkouts, relative to the home, where ciclo-fetch runs git fetch
#   origin before the round, outside the fence (their .git/ is read-only
#   inside it), 15 seconds per checkout, with the unit's start timeout sized
#   on the list; outcome in fetch.json of the state directory, with the ts
#   of the last successful fetch kept across failures (ultimo_riuscito).
{identity ? import ./identity}: {
  salute = {
    host = "deck";
    checkout = "salute";
    # 09:00 from 2026-10-24: Android's automatic clock sync arrives late and
    # the extra half hour gives it time (custodian, salute 1e599e7). 08:30
    # from 2026-10-20: the night and the early morning yoga or meditation
    # are usually in by then; the manual upload the custodian makes from
    # work enters the next day's round (custodian, salute 48497e8; 12:00
    # from 2026-10-11).
    cadence = "*-*-*";
    time = "09:00";
    state = "timer";
    readWritePaths = [
      "${identity.home.personalDrive}/salute"
      ".config/rclone" # rclone refreshes the OAuth token in rclone.conf
    ];
    # gog keeps its tokens in GNOME Keyring, written by the daemon over D-Bus:
    # ~/.config/gogcli is never written by a round (unchanged since 2026-05,
    # checked 2026-11-07), so it stays read-only.
    # The rest of custode's Drive stays read-only (checked by the probe).
    readOnlyPaths = [identity.home.personalDrive];
    # Sending mail stays with the custodian; the wrapper also covers aliases.
    wrappers.gog = ["--gmail-no-send"];
  };

  # deck runs the cycles of the repos it serves (presentations.nix): nixos
  # at 04:30, salute at 09:00, economia at 14:00 and method last at 15:00, so
  # that method's perceive finds the adopters' rounds of the day. Step 0 from
  # 2026-10-16 (custodian): started by hand, then the timers one at a time.
  economia = {
    host = "deck";
    checkout = "economia";
    cadence = "*-*-*";
    # 14:00 from 2026-10-21 (custodian): at 13:00 the custodian's open
    # session stopped the round; its 45 minutes end before method.
    time = "14:00";
    # The launcher profile's default 45 minutes end before method at 15:00.
    # Step 1 from 2026-10-16 (custodian): four manual rounds (economia
    # 368bf9a, 2430f5a, 882601a, 086f13b); the last two clean, the second
    # one's misfiled bill fixed by the custodian (cda8da0).
    state = "timer";
    # The round captures the mail and saves the pertinent attachments in
    # Drive economia (custodian, 2026-10-16). gog refreshes its token in GNOME
    # Keyring through the daemon, so ~/.config/gogcli stays read-only.
    readWritePaths = [
      "${identity.home.personalDrive}/economia"
    ];
    # The rest of custode's Drive stays read-only.
    readOnlyPaths = [identity.home.personalDrive];
    # Mail drafts yes, sending never (economia autonomy.md, ciclo-autonomo).
    wrappers.gog = ["--gmail-no-send"];
  };

  nixos = {
    host = "deck";
    checkout = "nixos";
    cadence = "*-*-*";
    # 04:30 from 2026-10-18 (custodian): the report is ready on waking.
    time = "04:30";
    # Step 1 from 2026-10-17 (custodian), without waiting for a round with
    # real bumps and switch: that part of the perimeter is tested by the
    # first round that finds them due (method o2/pilota-ciclo-autonomo.md).
    state = "timer";
    # /manutenzione bumps ia and home-manager and switches deck inside the
    # round (custodian, 2026-10-16): a switch relinks files all over the
    # home, so the home is writable and the fence is the harness alone.
    homeWritable = true;
  };

  method = {
    host = "deck";
    checkout = "method";
    cadence = "*-*-*";
    time = "15:00";
    # Step 1 from 2026-10-17 (custodian; method 519d162).
    state = "timer";
    # Fetch adopters' markers before the round, outside its read-only home.
    # example-org/nixos-ufficio, seventh adopter from 2026-11-04 (custodian;
    # method b03ee34), has no checkout on deck since 2026-11-12: the round
    # reads it on its host with `--ssh` (method 000730e), a session through
    # a Herdr ssh pane (method kb/session-messaging.md).
    fetch = identity.work.methodFetch;
  };
}
