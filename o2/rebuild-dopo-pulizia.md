---
sintesi: "I tre host girano sulla configurazione ripulita e unificata del 2026-11-11, con home e sistema allineati a HEAD."
ciclo: runtime
---

# Portare i tre host sulla configurazione ripulita

## Cosa aspetta

La revisione del 2026-11-11 ha cambiato configurazione di sistema e home in
due commit:

- `96f2ff7` — via Docker e `libvirtd` da `deck`; via `touchpad.nix`,
  `libvirtd` e le regole `172.16.0.0/12` da `game`; via `nvd` da tutti;
- `75e6d08` — utente, lingering, auto-login, accessi SSH e porta Syncthing
  nella baseline di sistema; ambiente comune nella baseline home.

Il secondo è un refactor: in valutazione contro il commit precedente i tre
host hanno gli stessi pacchetti, file home, unità, gruppi, chiavi, porte e
regole firewall, e cambia solo l'ordine degli elementi. Non è stato
verificato su un sistema attivato.

## Stato per host

- **`deck`** — home applicata e allineata (2026-11-11). Sistema: rebuild
  fatto dopo `96f2ff7`, da rifare per `75e6d08`.
- **`game`**, **`neve`** — niente applicato: erano spenti.

## Atti

Su ogni host, dal suo checkout aggiornato:

```bash
git pull --ff-only
o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake .#<host>
o3/scripts/con-identita.sh home-manager switch --flake .#stele@<host>
```

La home di `game` e `neve` si può applicare anche da `deck` con
`remoto allinea <host>`; il rebuild resta al custode sull'host.

## Cosa guardare dopo

- `systemctl --failed` e `systemctl --user --failed` vuoti; da `deck`,
  `remoto stato <host>` e poi `system-drift.sh` e `home-drift.sh` allineati;
- login grafico automatico e SSH dagli altri due host funzionanti: sono le
  parti spostate nella baseline;
- su `game`, `id stele` senza `libvirtd` e con `i2c`, `docker`; OpenRGB
  funzionante; se ComfyUI in container deve chiamare llama.cpp e trova la
  porta chiusa, la causa è la regola `172.16.0.0/12` tolta
  (`kb/game-local-llm.md`);
- su `neve`, scanner accessibile (gruppi `scanner`, `lp`).

## Criterio di chiusura

I tre host allineati a `HEAD` per sistema e home, nessuna unità fallita.
