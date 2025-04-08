# modules/system/services/greetd.nix
{pkgs, ...}: {
  # X server base config (senza display manager)
  services.xserver = {
    enable = true;

    # Keyboard
    xkb = {
      layout = "it";
      variant = "";
      options = "";
    };
  };

  # Impostazione della console
  console.keyMap = "it";

  # Configurazione greetd
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format \"%A %d %B %H:%M\" --remember --remember-session --greeting \"Benvenuto sul tuo sistema NixOS\" --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Crea la directory della cache per le funzionalità --remember*
  system.activationScripts.tuigreetCache = ''
    mkdir -p /var/cache/tuigreet
    chown greeter:greeter /var/cache/tuigreet
    chmod 0755 /var/cache/tuigreet
  '';

  # Assicurati che il gruppo greeter esista
  users.groups.greeter = {};

  # Configura l'utente greeter
  users.users.greeter = {
    group = "greeter";
    isSystemUser = true;
  };

  # Aggiungi tuigreet ai pacchetti di sistema
  environment.systemPackages = with pkgs; [
    greetd.tuigreet
  ];
}
