---
stato: maturo
---

# Home Manager

Gestione dichiarativa dell'ambiente utente. Usato in modalità **standalone** (non come modulo NixOS integrato).

## Modalità standalone

`homeConfigurations` nel `flake.nix` — separato da `nixosConfigurations`. Ogni profilo è `user@host`:

```nix
homeConfigurations."stele@deck" = home-manager.lib.homeManagerConfiguration { ... };
```

Struttura file:

```
o3/home/<user>/<host>.nix      # Configurazione specifica user@host
o3/modules/home/               # Moduli riutilizzabili tra profili
```

`o3/home/default.nix` importa i moduli home comuni per tutti i profili. Tra questi
c'è `o3/modules/home/md2pdf.nix`, che distribuisce il comando `md2pdf` e le sue
dipendenze in user space.

Altri wrapper CLI più piccoli sono raccolti nel nodo `home-cli-helpers`: helper
audio/display per `neve` e helper di rimontaggio Google Drive via rclone.

## Comando

```bash
o3/scripts/con-identita.sh home-manager switch --flake .#stele@deck
```

Eseguibile senza `sudo`; un agente può applicarlo direttamente entro i confini
di autorità dichiarati in `CLAUDE.md`.

Lo switch porta anche i servizi utente delle presentazioni permanenti
(`presentazione-<repo>`, modulo `o3/modules/home/presentations.nix`): su
`stele@deck`, gestibili con `systemctl --user`
(`network-architecture § Presentazione sulla LAN`).

Porta anche le unità dei cicli autonomi (`ciclo-<repo>`, modulo
`o3/modules/home/cicli.nix`, decisioni in `o3/cicli.nix`), generate solo
sull'host a cui ciascun repo è assegnato (nodo `cicli`).

## Verifica della home attiva

`o3/scripts/home-drift.sh` confronta il path della generazione attiva con
l'`activationPackage.outPath` valutato al commit `HEAD`. La chiamata senza
argomenti misura l'host locale; per un altro host riceve nome e riga
`home:` di `remoto stato`, oppure il path della generazione.

La lista `applicato_su` del registro di manutenzione segue i pin degli
input, non le modifiche ai moduli. La data della generazione e l'albero
inviato da `remoto` non provano la deriva: un commit di soli testi cambia
l'albero ma può lasciare identica la home. Il confronto restituisce
`allineato`, `deriva` o `non misurabile` e non scrive il registro.

La valutazione a HEAD non rappresenta un candidato modificato e ancora
da committare. Durante un update, la valutazione dei profili verifica che
si possano costruire; l'esito dello switch prova l'attivazione e
`systemctl --user --failed` ne controlla i servizi. Il confronto con HEAD
diventa pertinente al candidato solo quando quel contenuto è committato.

## Perché standalone

Aggiornamenti home indipendenti dal sistema. Rollback utente senza toccare il sistema. Le due timeline di aggiornamento (sistema vs utente) restano disaccoppiate. Dettaglio: method/design-principles.md.

Connessioni:

- [nix-flakes](nix-flakes.md)
- [nixos-rebuild](nixos-rebuild.md)
- [design-principles](../method/design-principles.md)
- [configuration-patterns](configuration-patterns.md)
- [project-extension](project-extension.md)
- [client-desktop-architecture](client-desktop-architecture.md)
- [home-cli-helpers](home-cli-helpers.md)
- [md2pdf](md2pdf.md)
- [cicli](cicli.md)
