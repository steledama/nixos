# remoto: fixed acts of the agent on the other home hosts, from deck.
#
# Usage: remoto stato|allinea game|neve
#   stato    read only
#   allinea  sends deck's index (the staged tree, the one about to be
#            committed) to ~/.cache/remoto/nixos on the host and runs
#            home-manager switch from there; then, when deck's HEAD carries
#            that same tree and is on origin, fast-forwards the host's
#            ~/nixos to it. Idempotent: a tree already switched is not
#            switched again, so the call after the push only moves the
#            checkout.
#
# So one commit can certify the hosts it was applied to: stage, allinea,
# commit with applicato_su, push, allinea again for the checkout.
#
# The remote commands are fixed in this script, built by Nix: the round
# cannot edit them (deny in o3/ciclo/permessi.json). norvegia and svezia run
# from example-org/nixos-ufficio since 2026-11-04: deck no longer acts on them, not
# even to read (goal.md, "Due repo, confine netto").
#
# Exit: 0 ok, 2 usage, 3 host unreachable (game and neve are usually off),
# 6 deck's working tree differs from the index (unstaged or untracked
# files), 10 remote checkout dirty, 11 remote branch not main, 12 remote
# HEAD differs after the pull, 13 remote pull failed; any other code is the
# failure of the remote command. Codes 10-13 come after a successful switch:
# only the checkout is behind.

usage() {
  echo "uso: remoto stato|allinea game|neve" >&2
  exit 2
}

[[ $# -eq 2 ]] || usage
azione=$1
host=$2
case "$azione" in stato | allinea) ;; *) usage ;; esac
case "$host" in
  game | neve) ;;
  norvegia | svezia)
    echo "remoto: $host vive nel repo example-org/nixos-ufficio, da deck nessun atto" >&2
    exit 2
    ;;
  *) usage ;;
esac

ssh_host() {
  ssh -o BatchMode=yes -o ConnectTimeout=5 "$host" "$@"
}

if ! ssh_host true 2>/dev/null; then
  echo "remoto: $host non raggiungibile" >&2
  exit 3
fi

if [[ "$azione" == stato ]]; then
  ssh_host bash -s <<'EOF'
echo "host: $(hostname)"
echo "uptime: $(uptime)"
echo "nixos: $(nixos-version)"
echo "sistema: $(readlink /run/current-system)"
echo "revisione: $(nixos-version --configuration-revision 2>/dev/null || echo assente)"
echo "home: $(home-manager generations 2>/dev/null | head -1)"
echo "albero inviato: $(cat ~/.cache/remoto/albero 2>/dev/null || echo nessuno)"
echo "home.json: $(cat ~/.local/state/nixos/home.json 2>/dev/null || echo assente)"
if [ -d ~/nixos/.git ]; then
  echo "checkout: $(git -C ~/nixos log -1 --format='%h %cI %s')"
  echo "branch: $(git -C ~/nixos branch --show-current)"
  echo "tree: $(git -C ~/nixos status --porcelain | wc -l) file modificati"
fi
echo "unità di sistema fallite:"
systemctl list-units --failed --no-legend --plain | sed 's/^/  /'
echo "unità utente fallite:"
systemctl --user list-units --failed --no-legend --plain | sed 's/^/  /'
EOF
  exit
fi

checkout=$HOME/nixos
albero=$(git -C "$checkout" write-tree)

inviato=$(ssh_host 'cat ~/.cache/remoto/albero 2>/dev/null || true')

# allinea: the index must be what deck itself switched from.
if ! git -C "$checkout" diff --quiet ||
  [[ -n "$(git -C "$checkout" ls-files --others --exclude-standard)" ]]; then
  echo "remoto: su deck ci sono modifiche non in staging, prima git add" >&2
  exit 6
fi

if [[ "$inviato" == "$albero" ]]; then
  echo "switch: albero ${albero:0:7} già applicato su $host"
else
  git -C "$checkout" archive --format=tar "$albero" |
    ssh_host 'rm -rf ~/.cache/remoto/nixos ~/.cache/remoto/albero &&
      mkdir -p ~/.cache/remoto/nixos && tar -x -C ~/.cache/remoto/nixos'
  ssh_host bash -s -- "$albero" <<'EOF'
set -eu
"$HOME/.cache/remoto/nixos/o3/scripts/con-identita.sh" home-manager switch --flake "path:$HOME/.cache/remoto/nixos#$USER@$(hostname)"
echo "$1" > ~/.cache/remoto/albero
echo "home: $(home-manager generations | head -1)"
EOF
  echo "switch: albero ${albero:0:7} applicato su $host"
fi

# The checkout follows only a commit that carries this tree and is on origin.
testa=$(git -C "$checkout" rev-parse HEAD)
if [[ "$(git -C "$checkout" rev-parse 'HEAD^{tree}')" != "$albero" ]] ||
  [[ "$testa" != "$(git -C "$checkout" rev-parse '@{u}')" ]]; then
  echo "checkout: in attesa di commit e push, poi di nuovo remoto allinea $host"
  exit 0
fi
ssh_host bash -s -- "$testa" <<'EOF'
set -eu
export GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="ssh -o BatchMode=yes"
cd ~/nixos
[ "$(git branch --show-current)" = main ] || { echo "checkout: branch non main" >&2; exit 11; }
[ -z "$(git status --porcelain)" ] || { echo "checkout: tree sporco" >&2; exit 10; }
git pull --ff-only -q || exit 13
[ "$(git rev-parse HEAD)" = "$1" ] || { echo "checkout: HEAD $(git rev-parse --short HEAD), atteso ${1:0:7}" >&2; exit 12; }
echo "checkout: ${1:0:7}"
EOF
