# pkgs/screen-locker.nix
# Script to lock screen with black background and poweroff monitor for niri and hyprland
{pkgs}:
pkgs.writeShellScriptBin "screen-locker" ''
  if pgrep -x "niri" > /dev/null; then
    ${pkgs.swaylock}/bin/swaylock -f -c 000000 &
    LOCK_PID=$!
    sleep 0.5
    niri msg action power-off-monitors
    wait $LOCK_PID
  elif pgrep -x "Hyprland" > /dev/null; then
    ${pkgs.swaylock}/bin/swaylock -f -c 000000 &
    LOCK_PID=$!
    sleep 0.5
    hyprctl dispatch dpms off
    wait $LOCK_PID
    hyprctl dispatch dpms on
  else
    # Fallback
    ${pkgs.swaylock}/bin/swaylock -f -c 000000
  fi
''
