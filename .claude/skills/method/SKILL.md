---
description: Revisiona il drift di nixos rispetto ai commit del metodo.
user-invocable: true
---

# method

Esegui questa skill dalla root di `nixos`. La copia canonica vive nel repo
`method`; questo fork conserva superfici, check e vincoli NixOS.

## Confini

- Non modificare altri repo adottanti.
- Non sostituire `/exec plan`.
- Non applicare automaticamente differenze editoriali o di dominio.
- Non eseguire rebuild, staging, commit o push come parte della review.
- Non usare la data come cursore: il cursore è uno SHA completo di `method`.

## Marker

Il cursore vive nel frontmatter di `i3/allineamento-metodo.md` — non in
root: la root ospita il symlink `method` verso il canone (`../method/kb`), e
un marker con nome simile accanto ad esso è un signifier ambiguo, non un
ledger onesto (verdetto del canone: filo `allineamento-marker-stadio`, chiuso, nella
storia git di `method`). Cursore (`method_commit`, `reviewed_at`, `status`) e verdetto
narrativo sono fusi in un solo file-i3, stessa forma «stato attuale
aggiornato in place» di ogni altro filo. `status: aligned` è ammesso solo
quando ogni cambiamento pertinente dell'intervallo **e ogni prescrizione
aperta in `o3/` di `method`** è applicato, già soddisfatto, registrato come
divergenza intenzionale o affidato a un task locale. `status:
action-required` non avanza `method_commit`. Il marker resta anche quando lo
stato è `aligned` e non ci sono tensioni: il cursore serve alla prossima
revisione, e la chiusura dei fili ordinari non ne autorizza la rimozione
(`method/verdict.md`).

## Procedura

1. Risolvi il repository canonico dal symlink:

   ```bash
   method_kb="$(readlink -f method)"
   method_repo="$(git -C "$method_kb" rev-parse --show-toplevel)"
   git -C "$method_repo" status --short
   git -C "$method_repo" log -1 --format='%H %ad %s' --date=short
   ```

   Aggiorna il checkout di `method` prima del confronto: se è pulito,
   `git -C "$method_repo" pull --ff-only` (`CLAUDE.md` «Pull remoto»; su
   `deck` ripubblica anche le viste di `method`). Il pull porta canone e
   prescrizioni ma non applica nulla: il recepimento resta soggetto al gate
   di questa skill. Se il checkout è dirty o diverge da `origin`, non fare
   merge né rebase: la revisione usa `HEAD` e dichiara il limite, comprese
   le modifiche non committate fuori intervallo.

2. Leggi `method_commit` dal frontmatter di `i3/allineamento-metodo.md`,
   verifica che sia un commit e che sia antenato del target. Il target
   predefinito è `HEAD`; se l'utente fornisce uno SHA o ref esplicito, usa
   quello dopo averlo verificato localmente.

3. Elenca i commit in ordine:

   ```bash
   git -C "$method_repo" log --reverse --format='%H%x09%ad%x09%s' \
     --date=short "<marker>..<target>"
   ```

4. Rileggi le prescrizioni aperte del canone. Il delta dei commit non basta:
   una prescrizione nata prima del cursore e rimasta aperta esce
   dall'intervallo, e il marker che avanza la coprirebbe senza rilettura.

   ```bash
   sed -n '/^## Contenuti/,$p' "$method_repo/o3/prescriptions.md"
   ```

   Apri ogni prescrizione elencata e verifica **nei file** di `nixos`, non nel
   marker né nella storia dei giri, se è pertinente e recepita; un `rg`
   mirato sulle superfici che nomina di solito basta (per il lessico, escludi
   il symlink `method/`). Una divergenza intenzionale già nel marker non si
   ri-segnala. Le prescrizioni entrano nella classificazione col nome
   `o3/<nome>.md` al posto del commit.

5. Controlla `README.md`, `CLAUDE.md`, `AGENTS.md`, file-ciclo e porte root,
   riferimenti ai nodi condivisi, `.claude/skills/`, `.codex/skills/`,
   `o3/` e `presentation/`, convenzioni strutturali e adattamenti già registrati.

6. Classifica ogni cambiamento e ogni prescrizione aperta come `gia-soddisfatto`, `diretto`,
   `adattamento`, `non-pertinente`, `divergenza-intenzionale` o `task-locale`.
   Presenta la classificazione prima delle modifiche.

7. Applica con giudizio. Non copiare skill canoniche alla cieca: preserva
   `alejandra`, `ruff`, `prettier`, `o3/tools/check.sh`, inventory/facts/coverage/
   fidelity, fonti dichiarative, vincoli Nix e distinzione o3/home/system.

8. Verifica almeno:

   ```bash
   python3 method/../o3/kb_tools.py --root . audit --format markdown
   python3 method/../o3/kb_tools.py --root . inventory
   python3 method/../o3/kb_tools.py --root . facts
   python3 method/../o3/kb_tools.py --root . coverage
   python3 method/../o3/kb_tools.py --root . fidelity
   o3/tools/check.sh
   ```

   `o3/tools/check.sh` copre la review ordinaria; aggiungi `--flake` quando
   serve verificare la flake. I rebuild restano soggetti alle autorizzazioni
   di `CLAUDE.md`.

9. Aggiorna `i3/allineamento-metodo.md` in place e riesegui la procedura
   sullo stesso target. L'intervallo vuoto è la prova di idempotenza.

## Chiusura

Riporta intervallo, prescrizioni aperte rilette e loro esito, conteggio per
esito, file modificati, task locali, marker, verifiche, diff e limiti delle
verifiche runtime.
