# cicli.nix
#
# Decisions of the autonomous cycle (method o2/dove-gira-il-ciclo-autonomo.md):
# for every repo, where and when its `eval all -> exec all -> commit` round
# runs. The mechanism lives in modules/home/cicli.nix and generates the
# units ciclo-<repo> only on the host named here: one value of `host` per
# repo, so "a single host keeps a repo's autonomous cycle" holds by construction.
#
# Boundary: nixos decides where and when, the repo decides what. The round's
# prompt (`prompt`) and the cycle's permissions (`settings`) are files of
# the repo; the module invokes them without knowing what the round does.
#
# Fields:
# - host: networking hostName of the only host that runs the autonomous cycle
#   (null only for state "esterno");
# - checkout: path of the checkout relative to the home;
# - branch: the branch the round expects; any other stops it;
# - cadence + time: OnCalendar of the timer, "<cadence> <time>";
# - maxRuntime: RuntimeMaxSec of the unit; maxBudgetUsd: --max-budget-usd;
# - state: "manuale" (unit present, started only by hand with systemctl
#   --user start), "timer" (scheduled), "esterno" (outside nixos, no unit);
# - settings, prompt: paths in the repo; defaults o3/ciclo/permessi.json and
#   o3/ciclo/prompt.md, shared by the cycle and presentation modules through
#   modules/home/ciclo/registry.nix;
# - giri: folder of the checkout, ignored by git, for tentativi.jsonl,
#   ultimo.json and giri/<id>.jsonl; default i1/giri, null to keep traces
#   in the unit's state directory. The view gets --ciclo-unita when non-null;
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
# - lanciatore: the unit runs method's canonical launcher (o3/lanciatore.py
#   of the checkout `canone`, default "method") instead of ciclo-avvio:
#   sessions, pull, traces in i1/giri and closing line are the launcher's,
#   time cap and budget come from the repo's o3/ciclo/lanciatore.toml
#   (defaults 45 minutes, 5 USD), so maxBudgetUsd is not read. The outer
#   unit has no namespace; the agent alone runs in the fence, a transient
#   unit ciclo-<repo>-agente capped at agentMaxRuntime, below maxRuntime.
{identity ? import ./identity}: {
  salute = {
    host = "deck";
    checkout = "salute";
    branch = "main";
    # 09:00 from 2026-10-24: Android's automatic clock sync arrives late and
    # the extra half hour gives it time (custodian, salute 1e599e7). 08:30
    # from 2026-10-20: the night and the early morning yoga or meditation
    # are usually in by then; the manual upload the custodian makes from
    # work enters the next day's round (custodian, salute 48497e8; 12:00
    # from 2026-10-11).
    cadence = "*-*-*";
    time = "09:00";
    # Canonical launcher from 2026-11-11 (custodian; method fce8afe,
    # o3/ciclo/fallback.md): quota observation in the closing line. Caps
    # nested as in method: launcher 45 minutes, agent unit 47, outer 50.
    lanciatore = true;
    maxRuntime = "50min";
    agentMaxRuntime = "47min";
    maxBudgetUsd = 5;
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
    branch = "main";
    cadence = "*-*-*";
    # 14:00 from 2026-10-21 (custodian): at 13:00 the custodian's open
    # session stopped the round; with maxRuntime it ends before method.
    time = "14:00";
    # Canonical launcher from 2026-11-11, as salute; 50 minutes still end
    # before method at 15:00.
    lanciatore = true;
    maxRuntime = "50min";
    agentMaxRuntime = "47min";
    maxBudgetUsd = 5;
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
    branch = "main";
    cadence = "*-*-*";
    # 04:30 from 2026-10-18 (custodian): the report is ready on waking, and
    # the round ends by 05:15 at worst.
    time = "04:30";
    maxRuntime = "45min";
    maxBudgetUsd = 5;
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
    branch = "main";
    cadence = "*-*-*";
    time = "15:00";
    # Canonical launcher from 2026-11-08 (custodian; method
    # o2/lanciatore-ciclo-nel-metodo.md, step 2, launcher at 477b442 or
    # later). Caps nested so each layer ends before the one around it:
    # launcher 45 minutes (profile), agent unit 47, outer unit 50.
    lanciatore = true;
    maxRuntime = "50min";
    agentMaxRuntime = "47min";
    # Step 1 from 2026-10-17 (custodian; method 519d162).
    state = "timer";
    # Fetch adopters' markers before the round, outside its read-only home.
    # nixos-lavoro: clone of example-org/nixos-ufficio, seventh adopter from
    # 2026-11-04 (custodian; method b03ee34), read only from GitHub.
    fetch = identity.work.methodFetch;
  };
}
