# secrets.nix
# Elenco delle chiavi pubbliche che possono decriptare i segreti.
[
  # TODO: Sostituisci con la chiave pubblica del tuo utente (es. da ~/.ssh/id_ed25519.pub)
  "ssh-ed25519 AAAA... your-user@host"

  # TODO: Sostituisci con la chiave pubblica dell'host pc-sviluppo (da /etc/ssh/ssh_host_ed25519_key.pub)
  "ssh-ed25519 AAAA... root@pc-sviluppo"

  # TODO: Sostituisci con la chiave pubblica dell'host srv-norvegia (da /etc/ssh/ssh_host_ed25519_key.pub)
  "ssh-ed25519 AAAA... root@srv-norvegia"
]
