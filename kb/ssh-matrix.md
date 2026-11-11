---
stato: maturo
---

# SSH matrix

Gli alias `ssh deck`, `ssh neve` e `ssh game` sono distribuiti via Home
Manager da `ssh-common.nix` e `ssh-home-lan.nix` in `o3/modules/home/`; solo
su deck `ssh-work-lan.nix` aggiunge `ssh norvegia` e `ssh svezia`. Gli indirizzi sono definiti in
`~/.config/nixos/identity/home.nix` e `~/.config/nixos/identity/work.nix`.

## Destinazioni

Tutti gli alias usano porta 22 e `~/.ssh/id_ed25519`:

- **norvegia** — utente `sviluppo`, `identity.work.lan.hosts.norvegia`;
- **svezia** — utente `sviluppo`, `identity.work.lan.hosts.svezia`;
- **deck** — utente `stele`, `identity.home.lan.hosts.deck`;
- **neve** — utente `stele`, `identity.home.lan.hosts.neve`;
- **game** — utente `stele`, `identity.home.lan.hosts.game`.

## Prerequisiti di routing

Un alias seleziona utente e destinazione, ma non apre un tunnel VPN.

- **Nella stessa LAN** — accesso diretto, con chiave autorizzata sul target.
- **Deck verso lavoro** — la VPN `lavoro` parte al boot
  (`network-architecture`, «Accesso all'ufficio da casa»): verificare la
  rotta verso la LAN ufficio.
- **Server lavoro verso casa** — solo dallo standby, col client VPN `casa`
  ad avvio manuale (`wireguard-home`; il client è nel repo
  `example-org/nixos-ufficio`).
- **Neve/game verso lavoro** — nessun accesso: al lavoro si entra solo da
  deck, né rotta né alias né nomi dei server su questi host.

SSH non è esposto su WAN. Per diagnosticare, controllare
prima `ip route get <ip-destinazione>` sull'host che apre la connessione.

Da `deck` l'agente non usa gli alias liberamente per gli atti: su `game` e
`neve` passa da `remoto` (`cicli § Atti remoti`). I server vivono nel repo
`example-org/nixos-ufficio`: gli alias `norvegia` e `svezia` restano
per le sessioni del custode, e da qui l'agente non agisce sui server.

I profili `sviluppo` dei server (repo `example-org/nixos-ufficio`) aggiungono a
`ssh game` un forwarding locale della porta 11434 verso llama.cpp, ma dal
2026-11-08 le loro chiavi non sono autorizzate su `game`. Prerequisiti, durata
della sessione e verifica dell’endpoint vivono in `game-local-llm`.

Autenticazione: su tutti gli host sshd accetta solo chiave pubblica
(`PasswordAuthentication = false`, `PermitRootLogin = "no"`, baseline in
`o3/hosts/default.nix`). Prima di rebuildare un host nuovo verificare che le
`authorized_keys` dell'utente siano già distribuite.

## Dal telefono

`telefono` entra su deck con Sherpr: tunnel WireGuard `casa` attivo,
host `10.20.0.1` (o `192.168.0.10` in LAN), porta 22, utente `stele`,
identità con chiave Ed25519 generata nell'app e dichiarata in
`identity.home.deckAuthorizedKeys.telefono-sherpr`.

Accesso collaudato dal custode il 2026-11-10. La precedente chiave JuiceSSH
è revocata: tolta dalla configurazione, non è più fra le chiavi del sistema
attivo dal rebuild del 2026-11-11.

Chi entra su deck come `stele` è dichiarato per intero in
`identity.home.deckAuthorizedKeys` (`norvegia`, `game`, `neve`,
`telefono-sherpr`):
ogni variazione è un commit con rebuild di deck. `svezia` non ha più accesso a
deck (custode, 2026-11-08).

Su `game` e `neve` valgono accessi minimi, solo gli altri due host della LAN
(custode, 2026-11-08): `identity.home.gameAuthorizedKeys` (`deck`, `neve`) e
`identity.home.neveAuthorizedKeys` (`deck`, `game`).

Su tutti gli host `services.openssh.authorizedKeysInHomedir = false`
(`o3/hosts/default.nix`, custode, 2026-11-08): sshd legge solo l'elenco generato
in `/etc/ssh/authorized_keys.d/`, e una riga in `~/.ssh/authorized_keys` non ha
effetto. Una chiave si aggiunge o si toglie soltanto con commit e rebuild; il
limite è che chi ha `sudo` può comunque cambiare la configurazione di sshd.

Un rifiuto della chiave appare in `journalctl -u sshd` come
`Connection closed by authenticating user stele 10.20.0.3 [preauth]`.
Inventario delle chiavi e revoca se il telefono si perde:
`secrets-management § Telefono telefono`.

Connessioni:

- [network-architecture](network-architecture.md)
- [wireguard-home](wireguard-home.md)
- [secrets-management](secrets-management.md)
- [game-local-llm](game-local-llm.md)
- [cicli](cicli.md)
