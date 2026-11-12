---
sintesi: "Codex torna dall'input `ai` come gli altri agenti: via l'input `nixpkgs-codex`, il suo override e l'eccezione nella skill."
ciclo: runtime
---

# Rimuovere il pin Codex dopo build su ai

## Cosa è arrivato

Il pin teneva Codex a 0.166.0 perché la 0.167.0 non compilava
(`aws-lc-sys`, NixOS/nixpkgs #585124, chiusa il 2026-11-09). Il
2026-11-12 la 0.167.0 di `nixos-unstable`, il ramo che segue `ai`, è in
cache.nixos.org: lo ha misurato `o3/scripts/home-versions.sh` nella
diagnosi `ia` del giro (colonna cache `✓`). Verdetto in
`i3/workaround-desktop-upstream.md`.

## Dove vive il pin

- `flake.nix`: l'input `nixpkgs-codex` col suo commento e l'override
  `codex = (import inputs.nixpkgs-codex {inherit system;}).codex;`
  nell'overlay di `pkgs-ai`;
- `flake.lock`: il nodo `nixpkgs-codex`, che esce con l'input;
- `.claude/skills/manutenzione/ia.md`, paragrafo «Pin temporaneo Codex»;
- `o3/scripts/home-versions.sh`: la lettura di `nixpkgs-codex` per Codex
  e la nota finale; il ripiego `// .nodes.ai.locked.rev` regge anche senza
  il nodo, la nota invece va tolta;
- `kb/development-environment.md`, il paragrafo sul pin;
- `i3/workaround-desktop-upstream.md`, la voce del pin: con lei e col
  wrapper Steam il filo si chiude.

## Atti

In sessione col custode, perché la rimozione tocca la skill
`/manutenzione` (`.claude/`, fuori dal perimetro del giro):

```bash
nix flake update ai
o3/scripts/con-identita.sh home-manager switch --flake .#stele@deck
```

dopo aver tolto input e override da `flake.nix`. È un atto home-level: nessun
rebuild di sistema. `game` e `neve` seguono con `remoto allinea` quando sono
accesi, o con `/manutenzione` da loro.

## Vincoli

- Prima `deck`, poi gli altri host: la cache vale per il rev di
  `nixos-unstable` letto il 2026-11-12; se `ai` aggiornato porta un Codex
  senza cache e la build fallisce, si ripristina il lock
  (`o3/scripts/ripristina-lock.sh`) e il pin resta.
- Un solo commit con `flake.nix`, `flake.lock`, skill, script, nodo e filo.

## Criterio di chiusura

Su `deck` `codex --version` riporta la versione di `ai`,
`o3/scripts/home-drift.sh` dà `allineato`, `home-versions.sh` non mostra
più la nota sul pin, e il nodo `nixpkgs-codex` non è in `flake.lock`.
