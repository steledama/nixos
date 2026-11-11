---
sintesi: "Rimuovere il wrapper Steam/PipeWire su game quando il fix upstream rende inutile il workaround."
ciclo: runtime
---

# Rimuovere steam-pipewire-wrapper dopo fix upstream

## Workaround attivo

`stele@game` ha un wrapper Home Manager (`o3/modules/home/steam-pipewire-wrapper.nix`,
importato in `o3/home/stele/game.nix`) che riavvia PipeWire prima del primo avvio
di Steam per aggirare un crash nella `libaudio.so` bundlata da Steam quando
incontra uno stato corrotto del socket PulseAudio/PipeWire.

File da rimuovere quando upstream chiude:

1. `o3/modules/home/steam-pipewire-wrapper.nix`
2. Import in `o3/home/stele/game.nix`
3. Rebuild home-manager su `game`: `home-manager switch --flake .#stele@game`

## Dipendenza upstream

Issue Valve: `ValveSoftware/steam-for-linux` #9289 (e collegate #9204, #9060).
Il crash è nella `libaudio.so` NAS bundlata da Steam, innescato da PipeWire.
Quando Valve rilascia un client che non usa più quel path o sostituisce
`libaudio.so`, il wrapper diventa inutile.

## Criterio di chiusura

Issue upstream chiusa **e** Steam si apre su `game` senza il wrapper dopo
`home-manager switch`. Verificare che nei log non compaia più
`libaudio.so`/PulseAudio nel thread che crashava.

---

## Storia diagnostica (2026-06-03)

<details>
<summary>Diagnosi completa del crash originale</summary>

**Causa:** segfault nella `libaudio.so` NAS bundlata da Steam, raggiunta via
path PulseAudio del runtime, innescato da uno stato corrotto di PipeWire.
Confermato via backtrace gdb — il thread `threaded-ml` (mainloop PulseAudio)
riceveva SIGSEGV in `libaudio.so` dopo una enumerazione GPU riuscita.

Corrisponde a `ValveSoftware/steam-for-linux` #9289/#9204 (più utenti con
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
