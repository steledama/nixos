---
stato: maturo
---

# Development workflow

Workflow Git e attivazione per mantenere ogni generazione riconducibile a una
revisione precisa. La regola centrale è: valida, committa localmente, attiva,
poi pubblica solo dopo la verifica.

## Sequenza ordinaria

1. modifica i file;
2. esegui la review locale;
3. controlla e committa una sola unità logica;
4. attiva al livello corretto;
5. verifica il comportamento;
6. il push del branch corrente su `origin` segue ogni commit riuscito; force
   push e altri branch solo su richiesta esplicita.

```bash
o3/tools/check.sh
git diff --check
git status --short
git add <file>
git commit -m "type(scope): descrizione"
```

Per una validazione più costosa usa `o3/tools/check.sh --flake`.

## Attivazione per livello

Modifiche Home Manager:

```bash
o3/scripts/con-identita.sh home-manager switch --flake .#<user>@<host>
```

Modifiche NixOS:

```bash
nixos-rebuild build --flake .#<host>
o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake .#<host>
```

Una modifica che attraversa system e home richiede entrambe le attivazioni; il
successo di una non dimostra quello dell'altra.

## Cambi sperimentali

Per modifiche rischiose usa un branch dedicato. Mantieni i commit piccoli e
costruibili, così il confronto e il rollback restano comprensibili. Non serve
preservare in questo nodo varianti passo-passo dello stesso workflow.

## Commit conventions

Formato: `type(scope): descrizione`.

- `feat` — nuova capacità;
- `fix` — correzione di comportamento;
- `refactor` — riorganizzazione senza cambio funzionale;
- `docs` — sola documentazione;
- `chore` — manutenzione e aggiornamenti.

Lo scope è normalmente un host, modulo o area. Il soggetto resta sotto 72
caratteri, senza punto finale, e descrive il cambiamento. Il razionale non ovvio
va nel corpo del commit o nel filo `i3/` pertinente.

## Rollback

Prima distingui il livello che ha fallito.

```bash
# sistema
sudo nixos-rebuild switch --rollback

# Home Manager
home-manager switch --rollback

# commit già condiviso
git revert <commit>
```

Per un commit locale non pubblicato, preferisci aggiungere una correzione o
usare un'operazione Git non distruttiva coerente con lo stato della working
tree. Non includere `reset --hard` nei runbook ordinari: può eliminare lavoro
non correlato.

## Tracciabilità

`system.configurationRevision` associa le generazioni NixOS al commit Git:

```bash
nixos-rebuild list-generations
```

Una working tree pulita al momento del rebuild rende la revisione affidabile;
una build dirty resta utile per collaudo, ma non offre la stessa provenienza.

La revisione attiva si legge con `nixos-version --configuration-revision`
(da `deck` per gli altri host, riga `revisione:` di `remoto stato`). Siccome
entra nel toplevel, il toplevel cambia a ogni commit e non dice se il
sistema è in deriva: lo dice `o3/scripts/system-drift.sh [host] [revisione]`,
che confronta i drv alla revisione attiva e a `HEAD` con l'opzione fissata
(solo valutazione) ed elenca i commit candidati quando differiscono. Dopo una
build dirty la deriva non è misurabile.

Per la home il gemello è `o3/scripts/home-drift.sh [host] [generazione] [checkout]`: la
generazione è l'`activationPackage` della configurazione, quindi il suo path
valutato a `HEAD` coincide con quello attivo se e solo se nessuno switch è
pendente. Un commit di soli testi non lo cambia (collaudo del 2026-10-24:
stesso path per `c9d1945` e `8c82aa4`).

Connessioni:

- [common-commands](common-commands.md)
- [development-environment](development-environment.md)
- [configuration-patterns](configuration-patterns.md)
- [home-manager](home-manager.md)
- [nixos-rebuild](nixos-rebuild.md)
