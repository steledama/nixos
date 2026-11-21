---
stato: maturo
---

# Troubleshooting

Router diagnostico per problemi trasversali. I rimedi specifici restano nei
nodi dei servizi, evitando copie che divergono.

## Prima fotografia

```bash
hostname
git status --short
systemctl --failed
systemctl --user --failed
df -h
free -h
journalctl --since "1 hour ago" -p warning
```

Annota host, generazione, ultimo cambiamento e livello coinvolto: sistema, Home
Manager, servizio utente, servizio di sistema, container o rete.

## Build Nix

- **file nuovo non visto dal flake** — aggiungilo all'indice Git e ripeti la
  build;
- **attributo mancante** — controlla import, nome dell'opzione e diff recente;
- **collisione di pacchetti** — verifica che l'applicazione sia dichiarata a un
  solo livello secondo `configuration-patterns`.

```bash
git diff
nix flake check
```

## Servizi

```bash
sudo systemctl status <servizio>
sudo journalctl -u <servizio> --since "30 minutes ago"
systemctl --user status <servizio>
journalctl --user -u <servizio> --since "30 minutes ago"
sudo ss -tulpn
```

Per timer modificati, verifica la prossima esecuzione e riavvia il timer, non il
servizio oneshot. Per Syncthing, rclone o WireGuard prosegui
nel rispettivo nodo.

## Accesso SSH

Prima di rimuovere una host key verifica se è cambiato davvero l'host: una
host key nuova dopo una reinstallazione è attesa, una divergenza senza
reinstallazione no.

Per `Permission denied`, confronta la chiave pubblica locale con le
autorizzazioni dichiarate nel repository. Non correggere manualmente
`authorized_keys` se NixOS lo gestisce.

## Spazio e generazioni

```bash
df -h
nix path-info -Sh /run/current-system
nix-collect-garbage --delete-old
```

La garbage collection di sistema richiede sudo e rimuove generazioni non più
referenziate: eseguila solo dopo aver verificato quali rollback vuoi conservare.

## Recovery

- generazione NixOS difettosa: seleziona una precedente dal menu systemd-boot;
- Home Manager difettoso: `home-manager switch --rollback`;
- sistema non avviabile: usa `disaster-recovery`.

Connessioni:

- [disaster-recovery](disaster-recovery.md)
- [syncthing-architecture](syncthing-architecture.md)
- [rclone-operations](rclone-operations.md)
- [wireguard-home](wireguard-home.md)
- [network-architecture](network-architecture.md)
