---
name: manutenzione
description: Valuta gli aggiornamenti ia/home-manager/casa e il debito upstream world; esegue gli update home autorizzati e i bump overlay, conserva diagnosi e attivazioni nel registro condiviso.
user-invocable: true
---

# manutenzione

Coordina diagnosi, aggiornamenti autorizzati e registrazione degli esiti.
Leggi `CLAUDE.md` e `autonomy.md` per i confini operativi. I rami sono file
interni, non skill aggiuntive: apri soltanto quelli selezionati sotto.

## Scope

`/manutenzione` o `all` processa le voci applicabili e dovute.
`ia|home-manager|casa|world` restringe il giro e forza il ramo
oltre la cadenza, con motivo concreto, senza scavalcare il debounce.
Un task world esplicito restringe ulteriormente quel ramo. Per le voci
saltate riusa l'esito registrato senza script versioni né changelog.

Le cadenze vivono in `i1/manutenzione.json`, modificabili quando
l'esperienza lo giustifica; il plan conserva il polso quotidiano.
`ia` è il nome di dominio, `ai` l'input flake.

## Due fasi

La procedura ha due fasi, **diagnosi** e **atti**. In sessione si compiono di
seguito. Nel ciclo autonomo la diagnosi sta in `perceive` e gli atti in
`perform`, dopo `compare` e `plan`, così il verdetto può ancora fermarli
(`cycle`, «Stadi»).

- **Diagnosi, in sola lettura** (passi 1-3): prospetto, derive, script
  versioni, confronto con upstream, changelog, rischio, `probe:` di `world`.
  Niente `nix flake update`, modifiche a `flake.nix`, switch, `remoto
allinea` né scritture del registro. Il ramo `casa`, gogcli a parte, finisce
  qui.
- **Atti** (passi 4-6): gli update e i bump dei rami dovuti, poi un solo
  `home-manager switch` per tutti, gli allineamenti, il registro e
  l'autovalutazione.

Un ramo che il verdetto o il piano fermano non si esegue e non si registra:
la sua data resta quella vecchia, così il giro seguente lo trova dovuto, e il
motivo sale in `Attenzione:`.

## Ordine del lavoro

1. Leggi [contesto](contesto.md): host, pull a tree pulito, prospetto
   `maintenance-due.sh`, registro e allineamenti. Da deck leggi anche
   [remoto](remoto.md) per `game` e `neve`.
   **Esegui i controlli di deriva home e sistema anche senza rami dovuti.**
   Un allineamento al pin noto si compie nella fase atti, senza riaprire la
   diagnosi.
2. Seleziona i rami dal prospetto e dallo scope; leggi solo i file necessari:
   - [ia](ia.md): tutti gli host; update dell'input ai e switch home.
   - [home-manager](home-manager.md): tutti gli host; update e switch home.
   - [casa](casa.md): deck/neve/game; diagnosi del pin comune, gogcli e
     voci host-specifiche. Bump overlay autorizzati, rebuild al custode.
   - [world](world.md): per titolo task con dipendenza `w<n>` e `probe:`; diagnosi
     upstream, eventuale prova attiva solo con opt-in, proposta di sblocco.
3. Ogni ramo restituisce delta e giudizio.
   [Valutazione](valutazione.md) serve ai rami versioni; [sistema](sistema.md)
   a casa; [overlay](overlay.md) solo per un bump azionabile.
   Le fonti upstream si consultano quando il giudizio del ramo lo richiede.
4. Fase atti: compi update e bump dei rami dovuti secondo i loro file, poi un
   solo switch della home, e riporta esito e host verificati.
5. Prima del commit applica il percorso [remoto](remoto.md) su deck per
   `game` e `neve` accesi. Distingui switch riuscito e aggiornamento del
   checkout dopo il push.
6. Leggi [chiusura](chiusura.md): registra anche «nessun delta», conserva
   il timestamp della diagnosi per i soli allineamenti, pubblica gli esiti
   entro l'autonomia vigente e tratta separatamente le proposte di task.
   Chiudi sempre con l'autovalutazione, anche senza una proposta.

## Contratto del giro

Il ramo determina l'arco: contesto e diagnosi producono percezioni;
changelog e freschezza sostengono l'interpretazione; rischio e opportunità
il confronto; update e registro l'esecuzione. Nel giro `perceive` compie la
fase diagnosi e `perform` la fase atti, che non la ripete. La manutenzione non porta trailer
`Esiti` né `Prossimo`; nel ciclo autonomo vale il commit unico del giro
previsto da `autonomy.md`.

Gli script versioni richiedono rete e possono essere lenti o incompleti.
Il lock cross-host dipende dalla freschezza del pull e dalla connettività:
non è una garanzia distribuita. I changelog sono ricerca puntuale, non un
audit di sicurezza sistematico. I limiti specifici vivono nei rami.
