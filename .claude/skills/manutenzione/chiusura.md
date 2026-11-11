# Registrazione e chiusura

Per ogni ramo effettivamente processato in questo run (eseguito o
diagnosticato, **incluso l'esito "nessun delta trovato"** — il lock del
[contesto](contesto.md) vale solo se anche un run vuoto viene registrato, non solo un run
con qualcosa da segnalare; esclusi solo i rami non
applicabili all'host o saltati per lock già attivo), sovrascrivi la sua voce in
`i1/manutenzione.json` con **data, ora (`HH:MM`) e host** di questo run —
non accodare: la voce precedente resta leggibile nel `git log` del file,
questo run è il presente. Per `casa` scrivi la voce **di gruppo**
(non annidata per host) quando hai eseguito la diagnosi condivisa, più
`casa.gogcli` se dovuto e `host_specifico.<host corrente>` per le voci
host-esclusive valutate in questo run; se hai solo eseguito il rebuild autorizzato su un host già
diagnosticato altrove, tocca **solo** `applicato_su` (append), non
riscrivere la diagnosi. Per `world` annida sotto il titolo del task (schema in [storico](references/storico.md), da leggere quando scrivi).
Il registro si scrive una volta sola, in fondo alla fase atti, anche per i
rami di sola diagnosi. Un ramo fermato dal verdetto o dal piano non si
registra (`SKILL.md`, «Due fasi»).
Si scrive con `o3/scripts/registro.sh '<filtro jq>' [--arg …]`: applica il
filtro in place, rifiuta un risultato che non sia un oggetto e formatta.
Si legge con Read o con `jq '<percorso>' i1/manutenzione.json` da solo,
mai con `python3`, che il giro non concede (`-c`, `-`, `-m json.tool`).

Aggiorna anche il marcatore globale `ultima_esecuzione` in testa al file
(data, ora, host, elenco dei rami toccati in questo run) — indipendentemente
dall'esito, è il colpo d'occhio su "quando/dove/cosa" dell'ultimo giro.

**Il commit e il push del solo file di log sono sempre autonomi, per
qualunque ramo** — senza chiedere conferma, subito dopo la scrittura: il
lock funziona solo se lo stato è immediatamente visibile agli altri host, e
il push segue ogni commit (`CLAUDE.md` «Push remoto»). Stagea **solo** `i1/manutenzione.json` (più
`flake.lock` quando il ramo è `ia`, e gli adeguamenti dei moduli home quando
è `home-manager`), commit `chore(skills): registra esito
/manutenzione <rami>`, poi `git push origin main` — a meno che il debounce
del [contesto](contesto.md) abbia già bloccato la scrittura.

Questa autonomia **non si estende** ad altro prodotto dallo stesso run: righe
promosse in `o1/plan.md`, file `o2/`, proposte di sblocco `world` restano un
commit separato, gate proponi-poi-applica di `method/skill.md` — **avvisa e
chiedi conferma prima di quel commit**, come per ogni altra modifica a
collezioni/register.

## Promozione dei finding

Un rischio alto con decisione rimandata non resta solo nel log. Prima offri
il percorso diretto, con comando e confini del [contesto](contesto.md): se il custode lo
esegue in sessione, basta il log, senza aprire e chiudere un task.
Promuovi quando rimanda, non risponde o serve una finestra dedicata.

- Cerca il task già esistente per host/motivo; aggiornalo solo se cambiano
  rischio o pacchetti. Un finding basso o di routine non genera proposte.
- Se nuovo, proponi una riga `runtime` nel plan e il dettaglio `o2/` con
  pacchetti, rischi, raccomandazione e criterio di chiusura. Scegli `Ob.`
  da `goal.md`; se nessun obiettivo calza, segnala il problema al custode.
  Si applica il gate della [registrazione](chiusura.md), non la sola autonomia del log.
- Quando la promozione è concordata e il comando include `nix flake
update <input>` (`nixpkgs` per casa), esegui
  quel passo non-sudo e includi il lock nello stesso commit di plan e task.
  Il rebuild resta separato: il custode applicherà un lock committato.
- Registra `promosso: "<titolo task>"` nel ramo, evitando nuove proposte
  dello stesso finding finché il task resta aperto.

Alla chiusura verificata, un solo commit rimuove riga del plan e file
`o2/`, riporta `promosso` a `null` e toglie la voce `world.<titolo>` del
registro, se c'è. Scrivi questo vincolo nella sezione `Chiusura` dei nuovi
task. Se una chiusura lo dimentica, il prospetto lo segnala come voce
orfana ([contesto](contesto.md), «Orfane») e il run seguente la toglie.

## Autovalutazione

La skill giudica anche sé stessa. Chiudi la valutazione con una nota breve:
quali passi sono costati tempo, chiamate, commit o dinieghi senza servire,
e al più **una** proposta concreta per migliorare la procedura (questa
skill, `remoto`, il prompt del giro, uno script di `o3/scripts/`). Niente
proposta se non ce n'è una vera: la nota vuota è un esito legittimo.

La proposta si registra in `i1/manutenzione.json`, voce
`autovalutazione` (`data`, `proposta`, `motivo`, `volte`): una proposta
equivalente a quella già registrata incrementa `volte`, una diversa la
sostituisce con `volte: 1`. A `volte: 3` diventa un task `o2/` col campo
`decidere:` nel frontmatter, collegato al plan (`confine-delega`), e la voce torna
vuota: tre giri che inciampano nello stesso punto sono un segnale, uno
solo può essere rumore. La proposta non si applica da sola, nemmeno dentro
il perimetro: cambia la procedura che il custode ha concordato. Il custode
può applicarla prima, leggendola nel resoconto: allora la voce torna vuota
nello stesso commit che la applica, così il giro dopo non la ritrova come
equivalente e non incrementa `volte`.

## Storico esiti

`i1/manutenzione.json` è il registro corrente, sovrascritto per voce;
la storia è `git log -p`. È un i1 perpetuo, dichiarato in
`i1/perceptions.md`, condiviso via Git per rendere il lock cross-host
visibile. Forma e granularità sono quelle dei rami; le scritture
seguono questa procedura. Quando scrivi una voce leggi
[lo schema](references/storico.md).

`ultima_esecuzione` è il colpo d'occhio su data/ora/host/rami appena
trattati, non una seconda fonte del lock. `pacchetti` e `nota` su `ia`
restano compatti; sulle diagnosi `rischio` e `nota` conservano il giudizio.
`verifica_attiva_su_cadenza` riguarda solo le verifiche comportamentali
world descritte nella loro sezione.
