# o3/identity/home.example.nix
#
# Template pubblicabile di ~/.config/nixos/identity/home.nix. Stessa forma, valori segnaposto.
# Copia in ~/.config/nixos/identity/home.nix e compila con i dati reali della tua rete casa.
# Vedi o3/identity/README.md.
{
  email = "user@example.com";
  gitName = "User";
  personalDrive = "Drive/gdrive-personale";
  deckEthernetMac = "02:00:00:00:00:10";
  rcloneMounts = {
    gdrive-personale = {
      remote = "gdrive-personale";
      mountPoint = "Drive/gdrive-personale";
    };
    gdrive-familiare = {
      remote = "gdrive-familiare";
      mountPoint = "Drive/gdrive-familiare";
      private = true;
    };
  };
  extraSsh.github-familiare = {
    HostName = "github.com";
    User = "git";
    IdentityFile = "~/.ssh/id_ed25519_familiare";
    IdentitiesOnly = true;
  };

  lan = {
    subnet = "192.168.0.0/24";
    gateway = "192.168.0.1";
    dns = "192.168.0.1;1.1.1.1;";
    hosts = {
      deck = "192.168.0.10";
      neve = "192.168.0.8";
      game = "192.168.0.9";
    };
  };

  printers = {
    im550 = "192.168.0.15";
  };

  deckAuthorizedKeys = {
    norvegia = "ssh-ed25519 REPLACE_WITH_NORVEGIA_SSH_PUBKEY sviluppo@example.com";
    game = "ssh-ed25519 REPLACE_WITH_GAME_SSH_PUBKEY user@example.com";
    neve = "ssh-ed25519 REPLACE_WITH_NEVE_SSH_PUBKEY user@example.com";
    telefono-sherpr = "ssh-ed25519 REPLACE_WITH_SHERPR_SSH_PUBKEY herdr-mobile:deck";
  };
  gameAuthorizedKeys = {
    deck = "ssh-ed25519 REPLACE_WITH_DECK_SSH_PUBKEY user@example.com";
    neve = "ssh-ed25519 REPLACE_WITH_NEVE_SSH_PUBKEY user@example.com";
  };
  neveAuthorizedKeys = {
    deck = "ssh-ed25519 REPLACE_WITH_DECK_SSH_PUBKEY user@example.com";
    game = "ssh-ed25519 REPLACE_WITH_GAME_SSH_PUBKEY user@example.com";
  };

  vpn = {
    endpoint = "home.example.com:51820";
    serverPublicKey = "REPLACE_WITH_HOME_VPN_SERVER_PUBKEY=";
    serverAddress = "10.20.0.1/24";
    subnet = "10.20.0.0/24";
    hosts = {
      telefono = {
        publicKey = "REPLACE_WITH_PHONE_VPN_PUBKEY=";
        address = "10.20.0.3/32";
      };
      norvegia = {
        publicKey = "REPLACE_WITH_NORVEGIA_VPN_PUBKEY=";
        address = "10.20.0.5/32";
      };
    };
  };

  # Progetto Google Cloud del client OAuth di gog e gdrive-personale
  # (world.md § Fonti): dato documentale, nessun modulo lo legge.
  gcloud = {
    projectId = "example-project-123456";
    projectNumber = "123456789012";
    displayName = "my-project-00000";
  };

  syncthing.deviceIds = {
    neve = "REPLACE-WITH-NEVE-SYNCTHING-DEVICE-ID";
    game = "REPLACE-WITH-GAME-SYNCTHING-DEVICE-ID";
    deck = "REPLACE-WITH-DECK-SYNCTHING-DEVICE-ID";
  };
}
