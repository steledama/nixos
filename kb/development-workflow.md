---
stato: maturo
---

# Development workflow

Workflow Git e attivazione per mantenere ogni generazione riconducibile a una
revisione precisa. La regola centrale è: valida, committa e pubblica, poi
attiva e verifica; se la verifica fallisce si torna indietro col rollback del
livello coinvolto, non riscrivendo la storia.

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
o3/scripts/con-identita.sh nixos-rebuild build --flake .#<host>
o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake .#<host>
```

Una modifica che attraversa system e home richiede entrambe le attivazioni; il
successo di una non dimostra quello dell'altra.

## Preparare eval e build sul destinatario

La preparazione predefinita si svolge sul sistema che verrà aggiornato:
deck su deck, game su game e neve su neve. Da deck, in sessione col custode,
si usano gli alias SSH degli altri due host per i comandi non-sudo
(`autonomy.md`, criterio `preparazione-remota`). Prima verificare che non
stia già lavorando allo stesso aggiornamento un'altra sessione sul target.

Pubblicare il lock comune, quindi sul destinatario verificare `~/nixos`
(branch `main`, tree pulito) e recepire il commit con `git pull --ff-only`.
Non proseguire con un checkout sporco o divergente. Avviare i comandi
in un servizio utente sul destinatario, indipendente dalla shell SSH.
Per esempio, dalla shell SSH di game:

```bash
systemd-run --user --unit=nixos-prepara-sistema \
  --property=Type=exec --property=RemainAfterExit=yes \
  --working-directory="$HOME/nixos" \
  "$HOME/nixos/o3/scripts/con-identita.sh" nix build --print-build-logs \
  --out-link /tmp/nixos-preparato-game \
  .#nixosConfigurations.game.config.system.build.toplevel

systemctl --user show nixos-prepara-sistema.service \
  -p ActiveState -p SubState -p Result -p ExecMainStatus
journalctl --user -u nixos-prepara-sistema.service -n 50 --no-pager
```

La build include la valutazione. Se serve solo eval, usare lo stesso schema
con unità `nixos-valuta-sistema` e comando
`nix eval --raw .#nixosConfigurations.game.config.system.build.toplevel.drvPath`.
Sostituire nome host e link per neve. Usare servizi, senza `--scope`,
`--pipe`, `--pty` o `--wait`: il lanciatore deve poter chiudere SSH mentre
il lavoro continua, con log ed esito interrogabili alla riconnessione.

Verificare prima `loginctl show-user "$USER" -p Linger`: sui tre host
`o3/hosts/default.nix` dichiara `linger = true` per l'utente principale,
così il manager utente resta disponibile dopo l'ultima disconnessione.
Il servizio sopravvive alla caduta di SSH e al riavvio dell'host che apre
la connessione, non al riavvio del destinatario che sta costruendo.

Con `RemainAfterExit=yes`, `active/exited`, `Result=success` e
`ExecMainStatus=0` indicano conclusione riuscita; `active/running` è ancora
in corso. Conservare l'esito fino alla verifica. Prima di una nuova
preparazione, controllare quella esistente; dopo averne letto l'esito,
liberare il nome con `systemctl --user stop nixos-prepara-sistema.service`
(e `reset-failed` se fallita). Non fermare una build ancora in corso.

Usare l'identità locale del target, lo stesso commit e gli stessi input
della successiva attivazione. Il link temporaneo conserva il risultato
dalla garbage collection fino al rebuild. Il custode esegue poi sullo stesso
host `o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake .#game`.
Una home standalone richiede ancora il proprio switch.

La valutazione calcola le derivazioni e può sfruttare la cache di eval;
non scarica né compila i pacchetti e la sua cache può differire tra utente
e root. La build realizza i risultati nello store locale, condiviso anche
con il successivo comando sudo: se le derivazioni sono identiche e i
risultati sono ancora presenti, il rebuild li riusa e resta soprattutto
l'attivazione. Il toplevel può cambiare se cambia la revisione del checkout,
pur riusando i pacchetti invariati.

Una build su un altro host è una verifica utile, ma accelera il target
solo se i risultati vengono trasferiti nel suo store. È un'eccezione da
motivare, non il percorso predefinito; su game lo stack CUDA beneficia
anche dell'hardware locale. I controlli aggregati del repository, incluso
`nix flake check`, restano eseguibili su deck e non sostituiscono queste
build sui destinatari.

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

La revisione dice da quale codice pubblico viene il sistema, mai
l'identità locale. Ha tre forme (`o3/hosts/default.nix`):

- `<rev>`: checkout pulito valutato senza override;
- `<rev>-dirty`: albero con modifiche non committate, con o senza identità;
- `nar:<narHash>`: checkout pulito con l'identità locale. L'override
  dell'input `identity` impedisce a Nix di scrivere il lock, e Nix toglie
  allora `rev` da `self` anche a checkout pulito; resta il `narHash` dei
  soli file tracciati, identico a quello di `nix flake metadata` sul commit.

La revisione attiva si legge con `nixos-version --configuration-revision`
(da `deck` per gli altri host, riga `revisione:` di `remoto stato`). Siccome
entra nel toplevel, il toplevel cambia a ogni commit e non dice se il
sistema è in deriva: lo dice `o3/scripts/system-drift.sh [host] [revisione]
[sistema]`, solo valutazione. Cerca il contenuto della revisione fra gli
ultimi 40 commit; con `narHash` non distingue commit con lo stesso albero.
Senza una corrispondenza verificata la provenienza resta sconosciuta:
non dimostra modifiche locali e può dipendere dalla finestra di ricerca
o dalla lettura dei metadati. Valuta poi `HEAD` con l'identità locale di oggi e la revisione
forzata a quella attiva: allineato se e solo se ottiene esattamente il
toplevel attivo. Il confronto vede codice, input e identità; se il sistema
non coincide nemmeno col proprio commit, la causa è un'identità o un input
cambiati dopo il build. Da `deck` il toplevel è la riga `sistema:` di
`remoto stato`; senza, resta il confronto dei drv fra revisione attiva e
`HEAD`, che non vede l'identità.

Per la home il gemello è `o3/scripts/home-drift.sh [host] [generazione] [checkout]`: la
generazione è l'`activationPackage` della configurazione, quindi il suo path
valutato a `HEAD` coincide con quello attivo se e solo se nessuno switch è
pendente. Un commit di soli testi non lo cambia (collaudo del 2026-10-24:
stesso path per due commit consecutivi).

Connessioni:

- [common-commands](common-commands.md)
- [development-environment](development-environment.md)
- [configuration-patterns](configuration-patterns.md)
- [home-manager](home-manager.md)
- [nixos-rebuild](nixos-rebuild.md)
