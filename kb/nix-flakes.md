---
stato: maturo
---

# Nix Flakes

Sistema di build e gestione dipendenze dichiarativo. `flake.nix` è il punto di ingresso dell'intera configurazione.

## Struttura flake.nix

Due output principali:

- `nixosConfigurations.<host>` — configurazioni NixOS per ogni host
- `homeConfigurations.<user>@<host>` — configurazioni home-manager standalone

`flake.lock` fissa le versioni di nixpkgs e home-manager. Committato nel repo per riproducibilità.

## Input nixpkgs separati: cadenze di aggiornamento

Due input seguono il branch `nixos-unstable` con lock indipendenti, così
sistema e stack agentico si aggiornano senza trascinarsi:

- **`nixpkgs`** — sistemi e home di `deck`, `game` e `neve`: libertà di
  sperimentare, aggiornamenti frequenti.
- **`ai`** — `pkgs-ai` per lo stack agentico home-manager (claude-code,
  codex, pi-coding-agent, herdr): aggiornato spesso, slegato dal sistema.

Accanto a questi vivono **pin chirurgici a revisione fissa**, che non seguono un
branch e servono un singolo pacchetto tramite overlay. Non sono una terza
copia del mondo: isolano un pacchetto dalla cadenza del suo input naturale.

- **`nixpkgs-whisper`** — `whisper-cpp` su `game`. Non è un workaround: è un
  pacchetto la cui build CUDA può durare ore, e senza pin ricompilerebbe a ogni
  bump di `nixpkgs` non correlato (kernel, Docker, Chromium). Ha quindi una
  **cadenza di bump propria e permanente**, governata da `/manutenzione`
  (`casa.game.pacchetti_dedicati.whisper-cpp` in `i1/manutenzione.json`), non
  dal ritmo di `nixpkgs`.
  La differenza conta quando si legge il flake: un pin con cadenza propria è
  struttura, un pin di workaround è debito con una condizione di chiusura.

- **`nixpkgs-codex`** — Codex dentro `pkgs-ai`. Questo invece è un pin di
  workaround: tiene Codex alla versione che costruisce finché l'input `ai`
  non ne offre una funzionante. Motivo e condizione di rimozione in
  `development-environment` e nella riga del plan.

`o3/modules/system/nix.nix` allinea `nix.nixPath` a `inputs.nixpkgs`, il pin
che costruisce realmente l'host, anche per i comandi Nix non-flake.

## Identità locale

Il flake non ha input verso altri repository. L'input `identity` punta ai
template pubblici di `o3/identity/` (`home.example.nix`, `work.example.nix`);
indirizzi, chiavi e account reali stanno nei file-dati locali
`~/.config/nixos/identity/{home,work}.nix`, che `o3/scripts/con-identita.sh`
passa come override senza scriverli nel lock. `work.nix` porta solo la VPN
esterna di `deck`. Bootstrap in `o3/identity/README.md`, pubblicabilità in
`secrets-management`.

## Comandi principali

```bash
nix flake check                    # Valuta gli output e costruisce i checks dichiarati
nix flake show                     # Mostra tutti gli output disponibili

# Aggiornamento per cadenza (NON usare `nix flake update` nudo: muove tutto)
nix flake update nixpkgs           # Sistemi e home degli host
nix flake update ai                # Solo lo stack agentico (pkgs-ai)
nix flake update home-manager      # Moduli home-manager (cadenza: /manutenzione)
# Whisper: prima cambiare la revisione esplicita dell'input in flake.nix
nix flake update nixpkgs-whisper   # Registra nel lock la revisione scelta
```

Un `nix flake update` senza argomenti aggiorna insieme gli input che seguono
branch: muove sistema e stack agentico nello stesso passo. Non
cambia invece la revisione esplicitamente fissata nell'URL di
`nixpkgs-whisper`: per avanzarla occorre scegliere e modificare quell'URL,
poi aggiornare il lock e verificare la build CUDA. Il solo update dell'input
non seleziona una nuova revisione.

Aggiornare un input alla volta.

## Riferimento nel repository

- `flake.nix` — root del repo, definisce input, overlay condivisi, tutti i
  `nixosConfigurations` e gli `homeConfigurations`
- `flake.lock` — lock file committato per riproducibilità; contiene una
  voce propria per ciascuno dei quattro input della famiglia nixpkgs
  (`nixpkgs`, `ai`, `nixpkgs-whisper`, `nixpkgs-codex`)

Connessioni:

- [home-manager](home-manager.md)
- [nixos-rebuild](nixos-rebuild.md)
- [configuration-patterns](configuration-patterns.md)
- [project-extension](project-extension.md)
- [development-workflow](development-workflow.md)
- [secrets-management](secrets-management.md)
- [Nix flake references](https://nix.dev/manual/nix/2.28/command-ref/new-cli/nix3-flake.html)
