# Indice dei nodi

Catalogo del dominio NixOS locale. Le descrizioni indicano la funzione
dominante di ogni nodo; per un percorso guidato per intento usa la sezione “Se
devi…” del README. I nodi metodologici vivono nel repository `~/method` e non
sono duplicati qui.

## Modello del sistema

- [configuration-patterns](configuration-patterns.md) — Livelli della configurazione, responsabilità, import e invarianti
- [client-desktop-architecture](client-desktop-architecture.md) — Ruoli dei tre host di casa, baseline desktop e differenze funzionali
- [network-architecture](network-architecture.md) — Rete casa, accesso all'ufficio, domini, forwarding e superfici esposte
- [home-lan-addresses](home-lan-addresses.md) — Piano IP della LAN casa, censimento, DHCP del router Wind Tre e stampante IM 550
- [ssh-matrix](ssh-matrix.md) — Alias SSH, utenti e prerequisiti di routing tra gli host
- [syncthing-architecture](syncthing-architecture.md) — Mesh casa e relazione con i mount Drive
- [rclone-gdrive](rclone-gdrive.md) — Modello corrente dei mount Google Drive
- [hardware-inventory](hardware-inventory.md) — Hardware che influenza configurazione, capacità e workaround

## Rete e VPN

- [wireguard-home](wireguard-home.md) — VPN casa con `deck` server e lo standby lavoro come client

## Diagnostica

- [troubleshooting](troubleshooting.md) — Router diagnostico trasversale: prima fotografia e instradamento ai nodi specifici

## Cicli autonomi

- [cicli](cicli.md) — Unità del ciclo autonomo per repo: decisioni, recinto, arresti ed esito dei tentativi

## Configurazione e sviluppo

- [nix-flakes](nix-flakes.md) — Output del flake, cadenze dei pin, pin chirurgici e aggiornamenti per input
- [home-manager](home-manager.md) — Home Manager standalone, profili e confine system/home
- [nixos-rebuild](nixos-rebuild.md) — Build e attivazione delle configurazioni NixOS
- [unfree-packages](unfree-packages.md) — Policy unfree, moduli responsabili e import nixpkgs isolati
- [project-extension](project-extension.md) — Runbook per aggiungere host, profili o moduli
- [development-workflow](development-workflow.md) — Validazione, commit, attivazione e rollback
- [development-environment](development-environment.md) — Baseline degli strumenti e aggiornamento dello stack agentico
- [common-commands](common-commands.md) — Reference compatta dei comandi ricorrenti
- [secrets-management](secrets-management.md) — Confine segreti/identità, vincoli di bootstrap, seed, backup e prova annuale
- [secret-inventory](secret-inventory.md) — Inventario dei segreti per voce: path, consumer, seed, prova e rotazione

## Strumenti e capability host

- [rclone-operations](rclone-operations.md) — Runbook rclone: setup account, gestione dei mount e diagnostica
- [home-cli-helpers](home-cli-helpers.md) — Wrapper Home Manager per audio, display, rclone e Steam
- [md2pdf](md2pdf.md) — Conversione Markdown in PDF con Pandoc, Mermaid e LaTeX
- [google-workspace-cli](google-workspace-cli.md) — Installazione e autenticazione per-host di `gog`
- [deck-user-services](deck-user-services.md) — Viste dei repo e PWA pressione servite da `deck` sulle reti private: unità, pubblicazione, firewall
- [game-local-llm](game-local-llm.md) — Endpoint llama.cpp, modelli LLM/OCR dichiarativi su `game`
- [game-live-transcription](game-live-transcription.md) — Modello Whisper, streaming e fallback di trascrizione su `game`

## Installazione e recovery

- [post-installation](post-installation.md) — Reinstallazione o setup di `deck`, `neve` e `game`: clone, segreti, primo boot e verifiche
- [disaster-recovery](disaster-recovery.md) — Recupero di un host non avviabile da live USB
