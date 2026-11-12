---
description: Crea un git commit seguendo le convenzioni del progetto nixos
user-invocable: true
---

Crea un git commit seguendo le convenzioni del progetto. È una base
(`method/skill-composition.md`): dal working tree a un commit verificato e
pubblicato. La parte deterministica è lo strumento del canone
`method/../o3/commit_gate.py`, col profilo locale `o3/commit_gate.toml`
(formatter e controlli di nixos); qui resta il giudizio.

## Pre-commit: controlli e confini della delega

Leggi `autonomy.md`, richiesta corrente e autorizzazioni operative di
`CLAUDE.md`. I controlli necessari e gli aggiornamenti pertinenti già delegati
si eseguono senza una nuova conferma. Chiedi solo per cambi di scopi,
territorio o delega, atti non autorizzati o incertezze decisive non
risolvibili dalle fonti. Un punto sospeso non blocca modifiche indipendenti e
verificabili.

**1. Controlli deterministici** — Formatter, audit, facts, coverage e
fidelity della KB (dentro `o3/tools/check.sh`, compresa la facet
`ciclo` come problemi `[FACET]`), verifica delle viste e test li lancia il
gate al passo 2 della procedura. Risolvi entro il mandato ciò che segnala.
Resta al giudizio il formato di un nodo nuovo o pesantemente modificato:
`stato:` in cima, `Connessioni:` in fondo, date in git; i task in
`o2/` portano `sintesi` + `ciclo`, senza `stato`. Non avviare implicitamente
`kb review`, revisione semantica profonda separata dal gate ordinario.

**2. Fili in i3/** — Se la sessione ha cambiato il verdetto su un filo/area
aperta (nuove decisioni architetturali, diagnosi falsificate, cambi di
approccio o assunzioni operative), aggiorna **in place** il filo pertinente
entro la delega vigente: stato corrente e motivo, non un'entry datata o un
elenco di file. Crea un filo solo per una tensione viva contro un obiettivo.
Se il filo si è chiuso, rimuovi il file e la sua riga in `i3/verdicts.md` dopo
aver conservato eventuali presidi di ipotesi; i cursori e i contratti correnti,
come `i3/allineamento-metodo.md`, restano. Chiedi al custode solo quando la
modifica supera il confine della delega. La manutenzione non richiede un
aggiornamento rituale del filo.

**3. I due check del ciclo di valutazione (i2/i3)** — Verifiche da eseguire;
eventuali decisioni seguono il confine della delega.

- **i2 — le viste sono ancora vere?** Non è una domanda di giudizio: la
  verifica della build (`python3 method/../o3/view/build.py --root . --check`) la lancia il
  gate. Contratti fra le fonti e presidio del
  compartimento stagno devono passare; un errore si corregge nelle fonti prima
  del commit. L'output non entra nel commit: `view/` è ignorata da git e la
  vista pubblicata la ricostruisce `deck` dal commit (cfr. `method/view.md`,
  «Freschezza»). Il giudizio resta solo su ciò che la build non copre: una sintesi
  locale (`i2/`, il deck `presentation/presentation.md`, tabelle o diagrammi
  KB) il cui _significato_ è cambiato va ripensata e ri-derivata dalla fonte
  tecnica dichiarativa, non solo rigenerata — è il presidio della fedeltà
  cognitiva.
- **i3 — il verdetto cambia?** Verifica se la modifica altera lo stato di un
  filo aperto o poggia su un'assunzione che merita di essere esplicita. Se sì,
  aggiorna il filo in `i3/` (punto 2) e valuta la propagazione a
  `o1/plan.md`/`o2/` (priorità, dipendenze, nuovi task: l'esito li segnala come handoff per
  `/exec plan`, senza compierli qui), ai
  puntatori ai segnali di `goal.md` (copertura da mantenere, senza ricopiare
  lo stato) o al Goal stesso (decisione del custode).

Dopo aver risolto le pre-check (o averle saltate), procedi con il commit:

1. Leggi lo stato: `git status`, `git diff`, `git diff --cached` e
   `git log --oneline -5` per lo stile dei messaggi recenti.

2. Confronta `git status` con la modifica **prima del gate**, che formatta
   i file cambiati: ogni file modificato o non tracciato deve appartenerle.
   Un file estraneo, di un'altra sessione o uno scarto, ferma il commit: non
   lo includi, non lo formatti e lo riferisci.

3. Lancia `python3 method/../o3/commit_gate.py prima --perimetro <file della
modifica>`: rifà il confronto prima di scrivere (uscita 3 con file fuori
   perimetro, senza formattare nulla), formatta i file cambiati
   (`alejandra`, `ruff`, `prettier`) e lancia i controlli del profilo,
   ciascuno solo quando è dovuto (`o3/tools/check.sh`, `build.py --check`, i
   test di `o3/view/` e `o3/scripts/`). Un controllo fallito ferma il commit
   finché non è corretto; un formatter assente è segnalato e saltato. Senza
   `--perimetro` il gate prende tutto il working tree: in sessione è
   ammesso, in un giro del lanciatore esce con 4. Subito prima dello staging
   lancia `python3 method/../o3/commit_gate.py verifica`: con 3 un file è
   cambiato o comparso dopo il gate, e il commit si ferma. Poi fai lo
   staging, anche intero (`git add -A`).

4. Scrivi un messaggio di commit conciso:
   - Usa conventional commits: `type(scope): description`
   - Tipi comuni: `feat`, `fix`, `refactor`, `docs`, `chore`
   - Scope: host, modulo o area, es. `docs(kb)`, `feat(home)`, `fix(wireguard)`
   - Una riga, sotto i 72 caratteri
   - Focalizzato sul perché operativo della modifica

   Eccezione: se il commit chiude un giro di `eval` o `exec`, aggiungi dopo
   la riga il trailer `Esiti:` con una parola per stadio invocato (`materia` o
   `vuoto`). Un giro senza file cambiati si committa comunque, con
   `--allow-empty` (cfr. `method/skill.md`). Se il giro ha invocato `exec plan`,
   aggiungi anche `Prossimo:` col prossimo task, `(confermato)` o
   `(cambiato, era <task>; <causa>)`, oppure `nessuno (<motivo>)`, come lo
   chiude `plan`.

   Ogni commit dichiara chi l'ha deciso (cfr. `method/consent.md`, consenso
   differito, e `autonomy.md`):

   - `Autonomia: concordato` se il custode ha deciso o ratificato la modifica
     concreta, anche lasciandone esplicitamente il modo all'agente;
     `Autonomia: agente` se l'ha decisa l'agente entro una delega, anche col
     custode presente in chat. L'avvio del ciclo non ratifica in anticipo le
     sue decisioni. Nei commit misti separa le decisioni quando possibile;
     altrimenti usa `agente` e dichiara i motivi pertinenti. Un commit senza
     il trailer, come quelli storici, si legge `concordato`;
   - solo con `Autonomia: agente`, `Impatto: basso|medio|alto` e almeno un
     `Impatto-motivo:` che dice cosa ha determinato il livello: il criterio di
     `autonomy.md` e il file o la sezione che l'ha fatto scattare, oppure
     `giudizio:` seguito dalla ragione quando l'agente ha alzato il livello.
     Il giudizio alza, non abbassa. Con più motivi si ripete il trailer e vale
     il livello più alto. Un commit `alto` porta la proposta, non l'atto: il
     messaggio nomina il file dove vive.

   Tutti i trailer stanno nell'**ultimo paragrafo** del messaggio, insieme:
   una riga vuota fra loro li nasconde a `%(trailers)`.

5. Crea il commit con il messaggio preparato:

   ```
   git commit -m "descrizione del commit" -m "Autonomia: concordato"
   git commit -m "descrizione del giro" -m "Esiti: perceive=vuoto interpret=materia compare=materia
   Autonomia: agente
   Impatto: medio
   Impatto-motivo: ciclo-delegato (autonomy.md, verdetto corretto su fonte verificata)"
   ```

6. Lancia `python3 method/../o3/commit_gate.py dopo` (`dopo --giro` nel
   ciclo autonomo): verifica i trailer dell'ultimo commit, compresi quelli
   di coautoria che non vanno aggiunti. Se segnala un errore, correggi con
   `git commit --amend` prima del push; dopo il push non si riscrive la
   storia, si dichiara l'errore.

7. Esegui `git push` del branch corrente su `origin` (autorizzato dal custode
   il 2026-10-08, `CLAUDE.md` «Push remoto») e riporta SHA ed esito. Se il
   push è rifiutato non forzarlo: fermati e riferisci.

8. Distingui l'applicazione dal commit:
   - modifiche solo in `o3/modules/home/` o `o3/home/`: Home Manager può essere
     applicato autonomamente con il profilo corretto;
   - modifiche in `o3/modules/system/` o `o3/hosts/`: non eseguire rebuild senza
     autorizzazione; indica l'host e il comando necessari;
   - modifiche solo documentali o agli strumenti: nessuna applicazione runtime.

Un errore dell'agente scoperto dopo il commit si dichiara nel resoconto e si
corregge con un nuovo commit che lascia traccia, senza riscrivere la storia
pubblicata (`method/consent.md`).

IMPORTANTE:

- NON usare `--no-verify`
- NON fare amend di commit già pubblicati salvo richiesta esplicita
  (`CLAUDE.md`): l'amend corregge solo il commit locale non ancora spinto
  (`git log @{u}..HEAD` lo elenca)
- NON fare `push --force` né push di altri branch salvo richiesta esplicita
- NON committare file con segreti (`.env`)
- NON aggiungere automaticamente trailer di attribuzione o coautoria riferiti a
  modelli, vendor o harness. Aggiungerli solo su richiesta esplicita dell'utente.
