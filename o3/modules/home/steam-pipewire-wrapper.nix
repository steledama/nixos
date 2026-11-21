# modules/home/steam-pipewire-wrapper.nix
# Steam launcher workaround for the PipeWire state crash seen on game.
{pkgs, ...}: let
  steamWrapper = pkgs.writeShellScriptBin "steam" ''
    set -u

    if ! ${pkgs.procps}/bin/pgrep -u "$USER" -x steamwebhelper >/dev/null 2>&1; then
      if ${pkgs.systemd}/bin/systemctl --user --quiet is-active pipewire.service >/dev/null 2>&1; then
        ${pkgs.systemd}/bin/systemctl --user restart \
          pipewire.service \
          wireplumber.service \
          pipewire-pulse.service >/dev/null 2>&1 || true
      fi
    fi

    exec /run/current-system/sw/bin/steam "$@"
  '';
in {
  home.packages = [steamWrapper];

  xdg.dataFile."applications/steam.desktop".text = ''
    [Desktop Entry]
    Name=Steam
    GenericName=Game Client
    Comment=Application for managing and playing games on Steam
    Exec=steam %U
    Icon=steam
    Terminal=false
    Type=Application
    Categories=Network;FileTransfer;Game;
    MimeType=x-scheme-handler/steam;x-scheme-handler/steamlink;
  '';
}
