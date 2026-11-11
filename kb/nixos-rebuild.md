---
stato: maturo
---

# nixos-rebuild

Comando per applicare la configurazione NixOS di sistema. Richiede `sudo` e
autorizzazione esplicita del custode. Se l'ambiente agente non può soddisfare il
prompt interattivo, il comando va lanciato dall'utente nel proprio terminale;
il confine stabile è l'autorità sul cambiamento di sistema, non la capacità di
uno specifico client.

## Comandi

```bash
# Valida e attiva (richiede sudo e autorizzazione esplicita)
o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake .

# Valida senza attivare (non richiede sudo: costruisce e basta)
o3/scripts/con-identita.sh nixos-rebuild build --flake .#<host>

# Target host specifico
o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake .#neve
```

Solo `switch` e `boot` toccano il sistema e richiedono `sudo`: `build` produce
un risultato nello store e un symlink `result` nella directory corrente, quindi
è la verifica che un agente può eseguire da solo.

Il wrapper non è facoltativo: senza, il flake costruisce i template pubblici
di `o3/identity/`, con chiavi SSH e indirizzi segnaposto. La build nuda resta
utile solo come controllo dei template; l'attivazione la ferma
`system.preSwitchChecks` in `o3/hosts/default.nix`, che riconosce i template
dall'attributo `template` e interrompe `switch`, `boot` e `test` prima di
toccare il sistema.

## Scope

Si applica ai file in `o3/modules/system/` e `o3/hosts/`. Modifiche in `o3/modules/home/` e `o3/home/` usano invece `home-manager switch` (senza sudo, ~10s).

Connessioni:

- [home-manager](home-manager.md)
- [nix-flakes](nix-flakes.md)
- [development-workflow](development-workflow.md)
