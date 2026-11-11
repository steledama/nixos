---
ciclo: runtime
---

# Ipotesi sulla clipboard di Chromium

Il 2026-10-26 su `deck` (niri 26.04, Chromium 156.0.8078.47) Chromium aveva
«Incolla» disattivato e non leggeva la clipboard. Le osservazioni della
sessione:

- `wl-paste` leggeva il contenuto, quindi la clipboard Wayland era
  integra.
- Chromium girava con `--ozone-platform=wayland`, cioè come client Wayland
  nativo.
- Fermato `wl-clip-persist`, anche un testo scritto con `wl-copy` restava
  invisibile a Chromium.
- In parallelo giravano due `xwayland-satellite`: uno avviato da
  `spawn-at-startup` in `o3/modules/home/niri.nix`, l'altro dall'integrazione
  di niri su `DISPLAY=:0`.
- Chromium era aperto dal 2026-10-25 alle 12:28, prima del
  `nixos-rebuild switch` delle 16:40 (`system-413`). Quel rebuild non
  cambiava le versioni di Chromium e di niri.

Il doppione è stato tolto (commit `bdb2c50`, switch home-manager, `kill`
dell'istanza in più). Subito dopo Chromium è stato chiuso del tutto
(`pgrep chromium` vuoto) e riaperto: l'incolla è tornato a funzionare.

**Affermazione:** la causa era uno stato interno del processo Chromium di
lunga durata, che aveva perso la selezione Wayland. Il doppione di
xwayland-satellite non c'entrava. Lo indicano due fatti: la clipboard X11
non entra nel percorso di un client Wayland nativo, e il guasto si
riproduceva anche con `wl-copy`. L'ipotesi resta aperta perché le due
correzioni sono avvenute una dopo l'altra, senza isolarle: la sequenza
non permette di distinguerle. Una seconda spiegazione possibile, non
verificata, è che il rebuild con Chromium aperto abbia lasciato un
processo a metà fra due generazioni.

## Presidio e riscontro

Orizzonte: la prossima ricorrenza segnalata dal custode, con riesame
entro il **2026-12-31** anche in assenza di eventi.

Riscontro atteso:

- **Smentita.** Il guasto ricompare con un solo xwayland-satellite e su un
  Chromium appena avviato; oppure il riavvio di Chromium non lo risolve.
- **Conferma.** Il guasto ricompare su un Chromium di lunga durata, magari
  dopo un rebuild, e il solo riavvio completo di Chromium lo risolve.

Alla ricorrenza vanno raccolti: l'avvio del processo
(`ps -o lstart= -p <pid>`), l'ultima generazione di sistema e di
home-manager, `pgrep -a xwayland-satellite` e `wl-paste --list-types`.

Se entro l'orizzonte non ci sono ricorrenze, l'ipotesi si chiude come «non
ricorsa», senza confermare la spiegazione.

## Fonti

- Sessione del 2026-10-26 su `deck`: misure dirette di processi, tipi della
  clipboard e generazioni dei profili.
- Commit `bdb2c50`: rimozione dello spawn duplicato.
