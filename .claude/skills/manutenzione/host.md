# Voci per host del ramo sistema

- **`host_specifico`** — sotto `sistema`, per ciò che non condivide la
  stessa risposta dei tre host (`gogcli` **non** ne fa parte: il suo pin è
  unico, sta a livello di `sistema`). Due meccanismi diversi
  secondo se il pacchetto ha un pin indipendente o segue il pin condiviso: `pacchetti_dedicati.<pacchetto>` (pin indipendente,
  compile-pesante) porta una cadenza propria; `pacchetti_host` (nessun pin proprio, versione determinata dallo stesso
  `nixpkgs` condiviso — es. `naps2`, `steam`/`heroic`/
  `mangohud`) **non ha una cadenza propria**: non esiste un'azione di
  aggiornamento indipendente da poter schedulare, il bump arriva da solo col
  rebuild di quell'host. Tracciato per `nixpkgs_rev_valutato`
  invece che per data/cadenza: revisionato (per il solo valore di preavviso
  su changelog/patch locali) quando la diagnosi del ramo gira su quell'host
  o quando l'host sta per allinearsi a un `nixpkgs_rev` non ancora
  revisionato per le sue righe host-esclusive. Lock: intra-host per entrambi.
  Azione: come il ramo padre.

Lo script sull'host rappresentante dà la
diagnosi comune e le sue righe esclusive: registra per queste
`nixpkgs_rev_valutato` al rev appena diagnosticato. Se è dovuta solo una
voce host-specifica, esegui lo script per estrarre quella; ignora le righe
comuni già coperte. Lo script emette anche righe non dovute: applica
sempre il filtro del [contesto](contesto.md).

## Controlli per host

- **`game` — CUDA e LLM/OCR:** `cudaSupport = true` e
  `cudaCapabilities = ["8.9"]` in `o3/modules/system/hardware/nvidia.nix`.
  `llama-cpp` segue il pin comune, ma pesa a sé sul rischio: build CUDA
  lunga e backend LLM/OCR della LAN. Dopo il rebuild verifica `/models`.
  `whisper-cpp` ha pin indipendente e cadenza propria in
  `sistema.host_specifico.game.pacchetti_dedicati`: pesa solo quando dovuto.
  Per entrambi la colonna C di `system-versions.sh` non prevede la build:
  verifica il path di nixos-unstable con la config predefinita, non la
  variante CUDA dell'host. Game ha anche `cache.nixos-cuda.org` (modulo
  NVIDIA, attiva dopo il rebuild): per sapere se il path CUDA scelto arriva
  dalla cache valuta il suo `outPath` con `con-identita.sh` e passalo a
  `o3/scripts/cache-status.sh -v <path> <cache…>`. La presenza vale per quel
  path, non per i bump successivi; un'assenza non ne dice da sola la causa.
- **`game` — gaming:** `steam`/`heroic`/`mangohud` vengono da
  `o3/modules/system/gaming.nix`, solo su game; sono `pacchetti_host`.
  Rischio normalmente basso salvo incompatibilità Proton/driver nelle
  note. Il wrapper home `steam-pipewire-wrapper.nix` (`stele@game`,
  issue #13174) è invece debito `world`, non cambia le loro versioni.
- **`neve` — scanner:** `naps2`, da
  `o3/modules/system/hardware/scanner.nix`, è `pacchetti_host`, senza
  patch locali dalla 8.6.0 (fix #784 upstream). Il delta di un bump va
  compilato, non solo valutato: è la build che rivela le patch rotte.
- **`deck` — gogcli:** overlay permanente in `flake.nix`, non debito da
  rimuovere; diagnosi e bump nel [ramo](sistema.md), contesto in
  `kb/google-workspace-cli.md`.

Se il rebuild porta un kernel nuovo, la valutazione **suggerisce il
riavvio** e i controlli post-boot (`uname -r` con la versione attesa,
`systemctl --failed` e `systemctl --user --failed`, `/models` su `game`).
Il riavvio non si registra: non entra in `applicato_su`, nei campi o nelle
note di `i1/manutenzione.json`, e non motiva un commit. `applicato_su`
traccia il rebuild, cioè il rev attivo; il riavvio rende effettivo solo il
kernel e si verifica sul sistema stesso (`uname -r`, `uptime -s`).

Per rischio, cache e raccomandazione vale [valutazione](valutazione.md);
per un delta overlay azionabile [overlay](overlay.md).

La diagnosi del ramo presume un pin e versioni comuni senza override
host-specifici. Se cambiano, rivaluta la condivisione e sposta le righe
differenti in `host_specifico`. Lo script emette anche righe non dovute:
filtrale col prospetto, senza rinnovare diagnosi già coperte.
