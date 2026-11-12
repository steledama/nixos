---
sintesi: "Anche il client a 64 bit crasha col riproduttore di #13174 su game: il wrapper resta finché Valve non corregge."
ciclo: runtime
---

# Rimuovere steam-pipewire-wrapper dopo la prova su game

## Workaround attivo

`stele@game` ha un wrapper Home Manager (`o3/modules/home/steam-pipewire-wrapper.nix`,
importato in `o3/home/stele/game.nix`) che riavvia PipeWire prima del primo avvio
di Steam per aggirare un crash nella `libaudio.so` bundlata da Steam quando
incontra uno stato corrotto del socket PulseAudio/PipeWire.

File da rimuovere quando upstream chiude:

1. `o3/modules/home/steam-pipewire-wrapper.nix`
2. Import in `o3/home/stele/game.nix`
3. Attivazione su `game`: `remoto allinea game` da `deck`

## Dipendenza upstream

Issue Valve viva: `ValveSoftware/steam-for-linux` **#13174** (aperta,
riaperta; Valve vi chiude come duplicati le segnalazioni nuove, es. #13434
del 2026-07-23). #9289 e #9204 sono le storiche: #9289 è ferma dal
2025-02-19, #9204 è chiusa dal 2023 e Valve rimanda a #13174 i casi nuovi.
Il crash è nella `libaudio.so` NAS bundlata in `ubuntu12_32/`, raggiunta
dalla `libpulse` del client; PipeWire è l'innesco, non il difetto. Su
#13174 c'è dal 2026-10-20 un riproduttore deterministico: un programma che
pubblica un device virtuale via API PipeWire fa crashare Steam (build
`1791918634`), mentre lo stesso device creato via API pulse no.

## Stato al 2026-11-12

- **PipeWire non basta.** Lock a 1.6.9, `nixos-unstable` a 1.6.11: le note
  di 1.6.10 e 1.6.11 non toccano questo percorso (fix JACK, Bluetooth,
  plugin ALSA, pulse-server). Il bump di `nixpkgs` non è condizione di
  rimozione.
- **Steam a 64 bit era la via sperata.** Client a 64 bit nel container Steam
  Runtime: beta dal 2026-10-15, stable dall'aggiornamento del 2026-11-11.
  Se il client a 64 bit non carica più la `libaudio.so` di `ubuntu12_32/`,
  il crash non ha più dove avvenire. Non verificato: nessun riscontro su
  #13174 dopo lo stable, e le librerie a 32 bit restano richieste.
- **Prima prova su `game` (2026-11-12, sera).** Client ancora a 32 bit
  (`ubuntu12_32/steam`, build `1792618285`, canale stable): carica la
  `libaudio.so` e `ubuntu12_64/steam` non esiste. Il bootstrap ha messo in
  coda proprio allora i pacchetti `*_steamrt64`: il client a 64 bit sta
  arrivando, non è ancora attivo. Avviato senza wrapper, Steam parte (ma
  PipeWire era pulito, dopo un riavvio); il riproduttore di #13174 lo fa
  crashare subito. Lo strumento vale anche su questo host: la prova si
  ripete identica col client a 64 bit.
- **Seconda prova, client a 64 bit (2026-11-12, sera).** Al riavvio il
  bootstrap è passato al client a 64 bit, che vive in `steamrt64/` (non in
  `ubuntu12_64/`, come si attendeva), build `1794424036`, dentro il
  container dello Steam Runtime. Carica però una propria
  `steamrt64/libaudio.so`: Valve ha ricompilato la libreria, non l'ha
  tolta. Il riproduttore lo fa crashare come il 32 bit. Il 64 bit non è la
  via d'uscita: il difetto sta nel codice di `libaudio`, non nell'ABI.
- **nixpkgs non deve fare nulla.** `steam-unwrapped` 1.0.0.87 è il
  bootstrap, il client si aggiorna da sé; l'incompatibilità del client a 64
  bit con l'FHS di NixOS (nixpkgs#505824) è chiusa dal 2026-04.

## Prova su game

Senza toccare la configurazione, quando `game` è libero:

1. Client attivo e librerie: `pgrep -a steam` (il client a 64 bit è
   `steamrt64/steam`); con Steam aperto, `grep libaudio /proc/<pid>/maps`
   dice se e quale `libaudio.so` è caricata. `exe` non è leggibile da fuori
   del container, nemmeno con `sudo`.
2. Avviare `/run/current-system/sw/bin/steam` direttamente, scavalcando il
   wrapper.
3. Con Steam aperto, lanciare il riproduttore di #13174 (commento del
   2026-10-20; copia in `~/steam-repro-13174.sh` su `game`):
   `nix-shell -p gcc pkg-config pipewire.dev --run 'bash steam-repro-13174.sh'`.
   Se Steam regge, il percorso del crash è chiuso. Un semplice
   avvio riuscito non prova nulla, perché il crash vuole uno stato PipeWire
   sporco.

## Criterio di chiusura

La prova su `game` passa, con o senza chiusura di #13174: conta il
comportamento sull'host. Poi si tolgono i file sopra, si attiva con
`remoto allinea game` da `deck` (home-level, `atti-remoti`) e si verifica
un avvio dal launcher. Se la prova fallisce, il task torna ad aspettare
#13174 (`w1` del plan).

---

## Storia diagnostica (2026-06-03)

<details>
<summary>Diagnosi completa del crash originale</summary>

**Causa:** segfault nella `libaudio.so` NAS bundlata da Steam, raggiunta via
path PulseAudio del runtime, innescato da uno stato corrotto di PipeWire.
Confermato via backtrace gdb — il thread `threaded-ml` (mainloop PulseAudio)
riceveva SIGSEGV in `libaudio.so` dopo una enumerazione GPU riuscita.

Corrisponde a `ValveSoftware/steam-for-linux` #9289/#9204, oggi #13174 (più utenti con
backtrace identico su Fedora, Debian, Ubuntu, NixOS con PipeWire).

**Fix immediato (workaround runtime):**

```bash
systemctl --user restart pipewire.service
steam
```

**Automatizzato (2026-06-05):** `steam-pipewire-wrapper.nix` — se
`steamwebhelper` non è già attivo, riavvia `pipewire`, `wireplumber` e
`pipewire-pulse` prima di delegare allo Steam di sistema.

**Piste false già escluse:** regressione Pressure Vessel, NVIDIA/Mesa GBM,
`STEAM_RUNTIME_PREFER_HOST_LIBRARIES`, `GBM_BACKENDS_PATH` override,
canale beta (puntava alla stessa build `1780352834`).

</details>

Connessioni:

- [client-desktop-architecture](../kb/client-desktop-architecture.md)
- [unfree-packages](../kb/unfree-packages.md)
- [nix-flakes](../kb/nix-flakes.md)
