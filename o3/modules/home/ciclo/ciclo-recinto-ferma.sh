# ciclo-recinto-ferma <systemctl> <unit>
#
# The --recinto-ferma of a launcher cycle (cicli.nix, lancia). From method
# accb3b5 the launcher runs it after every agent it started, normal exit
# included, and reads exit 0 as "the whole fence is gone": anything else is
# its code 25 and a persistent .git/lanciatore/fermo. So 0 only when
# verified:
#
# - systemctl stop, synchronous; "not loaded" (5) is fine, since --collect
#   unloads the transient unit as soon as the agent exits;
# - the unit is inactive or failed, or no longer loaded;
# - its cgroup, under app.slice of this user manager, is gone or empty.
#
# systemctl comes as an argument: the one of the running system, like the
# systemd-run of the fence.

systemctl=$1
unit=$2

root=$("$systemctl" --user show -p ControlGroup --value -- -.slice)
if [[ $root != /* ]]; then
  echo "ciclo-recinto-ferma: radice cgroup del manager ignota" >&2
  exit 1
fi

rc=0
"$systemctl" --user stop -- "$unit" 2>/dev/null || rc=$?

load='' active=''
while IFS='=' read -r chiave valore; do
  case $chiave in
  LoadState) load=$valore ;;
  ActiveState) active=$valore ;;
  esac
done < <("$systemctl" --user show -p LoadState,ActiveState -- "$unit")

case $active in
inactive | failed) ;;
*)
  echo "ciclo-recinto-ferma: $unit ancora ${active:-ignoto}" >&2
  exit 1
  ;;
esac
if ((rc != 0)) && [[ $load != not-found ]]; then
  echo "ciclo-recinto-ferma: stop di $unit uscito con $rc" >&2
  exit 1
fi

events="/sys/fs/cgroup${root%/}/app.slice/$unit/cgroup.events"
if [[ -e $events ]] && ! grep -qx 'populated 0' "$events"; then
  echo "ciclo-recinto-ferma: cgroup di $unit ancora popolato" >&2
  exit 1
fi
exit 0
