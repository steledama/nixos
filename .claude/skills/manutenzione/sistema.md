# Diagnosi condivisa dei sistemi

- **`host_specifico`** — sotto `casa`, per ciò che non condivide la
  stessa risposta del gruppo (`gogcli` **non** ne fa parte: il suo pin è
  unico per il gruppo, sta a livello di `casa`). Due meccanismi diversi
  secondo se il pacchetto ha un pin indipendente o segue il pin condiviso di
  gruppo: `pacchetti_dedicati.<pacchetto>` (pin indipendente,
  compile-pesante) porta una cadenza propria; `pacchetti_host` (nessun pin proprio, versione determinata dallo stesso
  `nixpkgs` del gruppo — es. `naps2`, `steam`/`heroic`/
  `mangohud`) **non ha una cadenza propria**: non esiste un'azione di
  aggiornamento indipendente da poter schedulare, il bump arriva da solo col
  rebuild di gruppo su quell'host. Tracciato per `nixpkgs_rev_valutato`
  invece che per data/cadenza: revisionato (per il solo valore di preavviso
  su changelog/patch locali) quando la diagnosi di gruppo gira su quell'host
  o quando l'host sta per allinearsi a un `nixpkgs_rev` non ancora
  revisionato per le sue righe host-esclusive. Lock: intra-host per entrambi.
  Azione: come il ramo padre.

Per `casa`, lo script sull'host rappresentante dà la
diagnosi comune e le sue righe esclusive: registra per queste
`nixpkgs_rev_valutato` al rev appena diagnosticato. Se è dovuta solo una
voce host-specifica, esegui lo script per estrarre quella; ignora le righe
di gruppo già coperte. Lo script emette anche righe non dovute: applica
sempre il filtro del [contesto](contesto.md).

## Controlli per host

- **`game` — CUDA e LLM/OCR:** `cudaSupport = true` e
  `cudaCapabilities = ["8.9"]` in `o3/modules/system/hardware/nvidia.nix`.
  `llama-cpp` segue il pin di gruppo, ma pesa a sé sul rischio: build CUDA
  lunga e backend LLM/OCR della LAN. Dopo il rebuild verifica `/models`.
  `whisper-cpp` ha pin indipendente e cadenza propria in
  `casa.host_specifico.game.pacchetti_dedicati`: pesa solo quando dovuto.
  Per entrambi `✗` in cache significa coda CUDA lunga.
- **`game` — gaming:** `steam`/`heroic`/`mangohud` vengono da
  `o3/modules/system/gaming.nix`, solo su game; sono `pacchetti_host`.
  Rischio normalmente basso salvo incompatibilità Proton/driver nelle
  note. Il wrapper home `steam-pipewire-wrapper.nix` (`stele@game`,
  issue #9289) è invece debito `world`, non cambia le loro versioni.
- **`neve` — scanner:** `naps2`, da
  `o3/modules/system/hardware/scanner.nix`, è `pacchetti_host`, senza
  patch locali dalla 8.6.0 (fix #784 upstream). Il delta di un bump va
  compilato, non solo valutato: è la build che rivela le patch rotte.
- **`deck`/`neve`/`game` — gogcli:** overlay permanente in `flake.nix`
  (decisione 2026-09-24), non debito da rimuovere. Confronta il pin con
  `gh release list --repo openclaw/gogcli --limit 1`, non con nixpkgs:
  `system-versions.sh` non lo include. Finding home-level a rischio basso,
  presentato prima della raccomandazione di rebuild; bump secondo [overlay](overlay.md).
  Contesto: `kb/google-workspace-cli.md`.

Se il rebuild porta un kernel nuovo, la valutazione **suggerisce il
riavvio** e i controlli post-boot (`uname -r` con la versione attesa,
`systemctl --failed` e `systemctl --user --failed`, `/models` su `game`).
Il riavvio non si registra: non entra in `applicato_su`, nei campi o nelle
note di `i1/manutenzione.json`, e non motiva un commit. `applicato_su`
traccia il rebuild, cioè il rev attivo; il riavvio rende effettivo solo il
kernel e si verifica sul sistema stesso (`uname -r`, `uptime -s`).

Leggi [valutazione](valutazione.md) per rischio, cache e raccomandazione.
Per un delta overlay azionabile leggi [overlay](overlay.md).

La diagnosi di gruppo presume un pin e versioni comuni senza override
host-specifici. Se cambiano, rivaluta la condivisione e sposta le righe
differenti in `host_specifico`. Lo script emette anche righe non dovute:
filtrale col prospetto, senza rinnovare diagnosi già coperte.
