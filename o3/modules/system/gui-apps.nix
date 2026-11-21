# modules/system/gui-apps.nix
# Terminale della base di soccorso, imported by the baseline o3/hosts/default.nix.
# Le app grafiche dell'utente vivono a home (modules/home/gui-apps.nix),
# per criterio di livello: kb/configuration-patterns.md.
{pkgs, ...}: {
  config = {
    # Foot terminal: il pacchetto vive qui (base di soccorso, usabile anche
    # quando la home non si attiva); le preferenze utente vivono nel modulo
    # home niri. Registra foot come terminale predefinito per xdg-terminal-exec
    environment.etc."xdg/xdg-terminals.list".text = "foot.desktop\n";

    environment.systemPackages = with pkgs; [
      foot # Fast standalone Wayland terminal
      xdg-terminal-exec # Handles Terminal=true desktop entries
    ];
  };
}
