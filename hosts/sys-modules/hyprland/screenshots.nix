{ config, pkgs, ... }:

let
  screenshot-area = pkgs.writeShellScriptBin "screenshot-area" ''
    grim -g "$(slurp)" - | wl-copy
    notify-send "Screenshot" "Area screenshot copied to clipboard"
  '';

  screenshot-full = pkgs.writeShellScriptBin "screenshot-full" ''
    grim - | wl-copy
    notify-send "Screenshot" "Full screenshot copied to clipboard"
  '';

  screenshot-window = pkgs.writeShellScriptBin "screenshot-window" ''
    grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | wl-copy
    notify-send "Screenshot" "Window screenshot copied to clipboard"
  '';
in
{
  environment.systemPackages = with pkgs; [
    grim
    slurp
    wl-clipboard
    screenshot-area
    screenshot-full
    screenshot-window
  ];

  # You can add any additional configuration here if needed in the future
}
