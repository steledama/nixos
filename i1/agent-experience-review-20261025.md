---
ciclo: dev
---

# Evidenze della revisione dell’esperienza dell’agente

## Provenienza e limiti

Raccolta del 2026-10-25. Le sezioni sul prototipo e sui dinieghi del 24
sono trasferite dalla specifica `o2/design-agent-as-user.md` a `ecdb2ba`:
conservano i riscontri e le attribuzioni già registrati, senza una nuova
verifica delle trascrizioni del 24 o del confronto svolto da method.
Le osservazioni del 25 distinguono il resoconto riportato dal custode dalle
letture dirette della sessione corrente.

## Prototipo exec: confronto registrato il 24

Mappa delle sezioni prima del consolidamento, discussa con la sessione
`method` via Herdr su autorizzazione del custode il 2026-10-24:

- ingresso, autorità e chiusura: contratto comune, resta in `SKILL.md`;
  il soggetto del commit vuoto è `/commit` quando richiesto, e il gate
  remoto rinvia al criterio vigente. Queste due correzioni sono applicate;
- `plan`, passi 1-3 e 4-5: procedura sulla coda e suoi controlli, candidata
  a `plan.md`; anche convenzioni e trailer `Prossimo:` appartengono qui;
- `plan`, passo 3b: domande operative con esempi di dominio. Valutare
  l'estrazione della spiegazione strategica verso un nodo già esistente;
  nel prototipo resta intatto, quindi non si dichiara ridotto il suo costo;
- `specify`: criteri di qualità applicati a un oggetto. Il prototipo
  esplicita `exec specify <task>`; senza oggetto resta la collezione;
- `perform`: procedura sugli atti e sulla collezione, candidata a
  `perform.md`, conservando il confine system/home;
- wrapper Codex: adattatore invariato verso l'ingresso comune.

Il prototipo è applicato in `.claude/skills/exec/`: separa le procedure
nella stessa cartella senza aggiungere skill. Il confronto statico verifica
le destinazioni; non è un collaudo
del comportamento. La sessione method concorda sull'ingresso selettivo e
richiede oggetto esplicito, mappa delle sezioni e struttura confrontabile
col canone. La separazione resta sperimentale finché non è collaudata e
allineata; nessuna modifica del canone via symlink.

Durante la prova è emerso che `skill_tools.py` conta le righe dei file
accanto ma analizza comandi, divieti e trailer solo in `SKILL.md`. La
separazione richiede prima il controllo dei file di supporto: altrimenti
il minor numero di segnalazioni sarebbe perdita di copertura. Il limite è
stato segnalato a method e corretto nel canone con `e2018a6`. La sessione
method ha confrontato vecchio e nuovo guardiano su una copia isolata del
prototipo: il nuovo conserva le due segnalazioni di `perform` e gli esiti
di divieti, trailer e composizione; il vecchio perdeva le due segnalazioni.
Il guardiano viene eseguito dal canone via `method/../o3/skill_tools.py`:
gli altri checkout che usano la separazione devono disporre di `e2018a6`
o successivo per conservarne la copertura.

Misura statica della prova: nucleo comune 76 righe, `specify` 26, `plan`
150, `perform` 30. Singolo task: 102 righe contro 264 iniziali; coda: 226;
`all`: 282. Il costo completo cresce di 18 righe. Le procedure di `plan`
e `perform` sono identiche; in `specify` cambia soltanto la selezione
esplicita dell'oggetto. Il bootstrap non è incluso in questi numeri.

## Dinieghi: casi registrati il 24

Attrito accertato: la brace expansion nei path (`wc … {a,b}/SKILL.md`, giro
del 2026-10-22, prova isolata del canone `771388b`), un turno di costo.

Giro del 2026-10-24, tre dinieghi:

- `home-manager generations | head -2; cd … && jq …` — causa non accertata:
  l'agente ha rinunciato al gesto senza riprovarlo, e `home-manager
generations` da solo è negli allow. Il gesto era legittimo e il suo esito
  contava: la home di `deck` era ferma a `7efdbc9`, senza `8c82aa4`, e
  nessuno strumento del giro poteva vederlo (`system-drift.sh` misura il
  sistema, `remoto stato` non gira su `deck`). La stessa cecità ha prodotto
  nel resoconto una causa sbagliata per `norvegia` («indietro su crm», ma
  `7444ca7` tocca solo `o3/hosts/`), dedotta dalle date delle generazioni.
  Lacuna, chiusa il 2026-10-24 con `o3/scripts/home-drift.sh` (punto 4).
- `python3 - <<EOF` per aggiornare `i1/manutenzione.json` — vincolo
  (`python3 -` è negato), recuperato con `Edit`. Ricorre: il 2026-10-21 era
  `python3 -c` sul registro dei giri. Vedi punto 5.
- `Write /tmp/ciclo-msg.txt` per il messaggio di commit — vincolo voluto
  (il giro scrive solo nel repo), recuperato con `git commit -m`.

## Revisione dell’altra istanza riportata dal custode

Il resoconto fornito in chat dichiara: host rilevato prima delle letture,
ricerca del titolo prima del README, fonti senza troncamento e distinzione
fra revisione ed esecuzione. La trascrizione originale non è stata
ispezionata qui; manca una misura completa di letture e turni. È una prova
riferita con esito misto, non una dimostrazione di comportamento stabile.

## Riscontri diretti sul giro del 25

Fonti lette: `i1/giri/ultimo.json`, trascrizione locale
`i1/giri/giri/e4852771891d415689f267b1f20dd016.jsonl`, registro
`i1/manutenzione.json`. I log locali non sono versionati: si conservano qui
solo i dati necessari alla revisione.

- Chiusura alle 04:43:25 +01:00: riuscito, 71 turni, 790289 ms,
  `permission_denials: 0`, commit `067ecc2`, push riuscito.
- Fra i comandi della trascrizione, `home-drift.sh` è chiamato solo per
  `svezia`, con la riga della home attiva. Nessuna chiamata su `deck`:
  il collaudo dello strumento sui due contesti resta parziale.
- Sono presenti due chiamate `remoto allinea norvegia`, prima e dopo il
  commit; il commit dichiara switch su deck e standby norvegia riusciti,
  generazione 157 e nessuna unità fallita. Non è una prova del passaggio
  del custode sulla production: svezia resta affidata al custode.
- Il registro conserva aggiornamenti ia, home-manager e gogcli su deck.
  Il giro offre quindi materiale per il percorso home-level e quello
  remoto; non ne è stata ancora ricostruita qui l’intera sequenza di
  orientamento, scelta, azione e verifica.
- L’aggiornamento di `i1/manutenzione.json` usa `o3/scripts/registro.sh`
  con filtro jq e argomenti. Lo strumento esistente accetta già il filtro
  sul registro di manutenzione: non manca ogni interfaccia di scrittura.
- Zero dinieghi non prova l’assenza di lacune, rinunce o cartelli e non
  esercita la classificazione. Nessun avanzamento automatico del conteggio
  dei tre giri puliti è dedotto da questo solo campo.

## Sessione corrente: limiti della prova d’ingresso

Il primo comando è stato `hostname` (deck); il task è stato raggiunto
tramite plan e indice o2, senza ricerca del titolo. Le letture sono state
restituite senza troncamento e lo scope dichiarato come revisione.
La sessione conosceva però già il resoconto e i criteri attesi: questo è un
riscontro assistito, non il collaudo indipendente dell’ingresso in una
sessione nuova. Non si attribuisce un risparmio di turni non misurato.

## Percorso home-level ricostruito e ristrutturazione di manutenzione

Fonte diretta: stream `e4852771891d415689f267b1f20dd016`, giro concluso
con `067ecc2`. I numeri seguenti sono righe JSONL della traccia locale,
non turni attribuiti al solo ramo: il giro intreccia ia, home-manager,
casa e gogcli.

- Ingresso: misura dei file alla riga 14; letture di manutenzione alle
  righe 37 e 48, con risposte di 220 e 410 righe, 13445 e 24752 caratteri
  incluse le annotazioni del tool. Sono due letture per 630 righe
  restituite (gli intervalli si sovrappongono sulla riga 220). Il
  prospetto della riga 39 dà home-manager dovuto a sette giorni,
  insieme a ia, casa e gogcli; lavoro, Docker e world non sono dovuti.
- Scelta: rev locale alla riga 53, master upstream alla 54 e confronto
  dei commit alla 77: `6407259` → `c216bf5`. Il collaudo parte da deck.
- Azione: update alla 84; elenco dei profili alla 119, cinque valutazioni
  alle 121–126. Tutte restituiscono un drv, senza warning di modulo;
  compare il warning del tree sporco. Switch locale alla 142, attivazione
  completata e zero unità utente fallite alla 151. La traccia invita a
  leggere `home-manager news`, ma non contiene quella chiamata.
- Registrazione: lettura del registro alla 153, lettura del writer alla
  206, uso di `registro.sh` alla 211. Alla 244 lo standby entra nella
  bozza; staging alla 248 e allineamento di norvegia alla 255. Lo switch
  riesce, il checkout attende il commit. Dopo commit/push, la chiamata
  289 conserva lo switch già fatto e porta il checkout a `067ecc2`.
  `remoto stato` alla 294 conferma generazione 157, rev home-manager
  `c216bf5`, checkout pulito e nessuna unità fallita.
- Limiti: nessuna chiamata `home-drift.sh` su deck nel giro, presente
  soltanto su svezia alla 194. La valutazione dei drv non dimostra da sola
  l'attivazione; qui la sostengono anche l'output dello switch e il
  controllo dei servizi. Nessuna prova del successivo atto del custode
  sulla production. I 71 turni e 790289 ms sono del giro intero, non
  una misura del costo di home-manager.

Mappa della ristrutturazione applicata nella sessione:

- Introduzione, scope e ordine degli atti → nucleo `SKILL.md`; matrice
  dei rami → contratti nei sei file omonimi. Nessuna nuova skill nel catalogo.
- Passi 1–2 → `contesto.md`: resta l'interpretazione del prospetto; il
  calcolo è di `maintenance-due.sh`, senza una seconda implementazione.
- Altri host da deck → `remoto.md`, letto su deck; confini e meccanismo
  restano quelli di `autonomy.md` e `kb/cicli.md`.
- Passi 3 e 8 → rami pertinenti; procedura overlay → `overlay.md`, solo
  quando c'è un bump azionabile. Nessun nuovo script: quelli esistenti
  coprono già prospetto, versioni, deriva, ripristino del lock e writer.
- Passi 4–7 → `valutazione.md`; controlli per host e granularità delle
  diagnosi → `sistema.md`, condiviso da casa/lavoro. Fonti upstream →
  `references/upstream.md`, aperto quando servono le note.
- Passi 9–11 → `chiusura.md`; schema mantenuto in
  `references/storico.md`, letto alla scrittura. I rami restituiscono
  esiti alla chiusura, senza copiare lo schema.
- Spiegazione di generazione attiva, pin e confronto a HEAD →
  `kb/home-manager.md`, «Verifica della home attiva»; il contesto conserva
  i comandi e il rimando. L'asimmetria home/nixpkgs è già documentata
  lì e in `kb/nix-flakes.md`, quindi non si ricopia nei limiti della skill.
- Limiti → nucleo o ramo pertinente. Debounce, soli allineamenti,
  fallimenti, guardrail casa/server, tutela production e opt-in world
  restano raggiungibili nei rispettivi percorsi.

Il nucleo rende esplicito il controllo della deriva anche con tutti i
rami non dovuti. La nuova disposizione porta la valutazione del ramo
home-manager prima dell'update e mantiene la lettura delle news dopo lo
switch. Sono indicazioni già presenti, rese raggiungibili nel percorso.

Prova locale dello strumento: `o3/scripts/home-drift.sh` su deck, a HEAD
`65aa70b`, legge la home attiva
`/nix/store/nzvm38c6vbirbdr60z1nprv77pih2nvi-home-manager-generation`
e valuta a HEAD
`/nix/store/9sfsxy3zcvi383cnn92h85i3jwajlif5-home-manager-generation`:
verdetto `deriva`, uscita 0. Il primo tentativo è stato fermato dal sandbox
Codex sull'accesso SQLite alla cache Nix; rieseguito con escalation.
È una prova dello strumento locale, non del suo uso spontaneo nel giro
né dell'attivazione della generazione attesa. Non è stato fatto uno switch.

Il collaudo runtime della skill resta da svolgere nel prossimo giro
pertinente: lettura dei soli rami selezionati, controllo home su deck,
esiti equivalenti, nessun nuovo diniego. Non si deducono turni risparmiati
dalle sole dimensioni dei file e non avanza il conteggio dei tre giri.

### Verifiche statiche della ristrutturazione

Misure sui soli file della skill, senza bootstrap, KB, output degli
script o ripetizioni: prima 630 righe di nucleo e 124 di schema, 754 in
totale; dopo 68 di nucleo e 715 nei file accanto, 783 totali (+29).
Il percorso home-manager su deck attraversa nucleo, contesto, remoto,
ramo home-manager, valutazione, fonti, chiusura e schema: 546 righe.
Senza rami dovuti e senza scrittura, nucleo/contesto/remoto/chiusura sono
291 righe. Sono costi statici di percorsi dichiarati, non misure runtime;
se tutti i rami servono, si legge un corpus complessivamente più grande.

Rilettura dei percorsi condizionali sui file, senza atti sul sistema:

- home-manager su deck: confronto rev e commit, valutazione dei cinque
  profili, ripristino lock in caso di errore non banale, switch e servizi,
  news, allineamento standby, registrazione e commit;
- tutti i rami non dovuti: controlli home/sistema e allineamento separati
  dal lock; nessun caricamento richiesto dei sei rami per rifare diagnosi;
- scope forzato entro dieci minuti: debounce ancora applicato, soli
  allineamenti senza rinnovo della data di diagnosi;
- ramo home-manager da server: bump lasciato a casa, guardrail sui pin
  prima dello switch e tutela per ruolo in remoto;
- world: opt-in per build attiva e proposta di sblocco distinta dalla
  rimozione del codice; casa/lavoro conservano rebuild al custode.

Questa è una revisione assistita delle istruzioni, non una prova
indipendente del comportamento dell'agente. I rimandi locali sono stati
verificati; `o3/tools/check.sh`, `build.py --check` e `git diff --check`
passano. Il guardiano canonico delle skill conserva le segnalazioni
preesistenti su `--custode` e `nixos-rebuild`, ora nei supporti remoto e
overlay, senza nuove segnalazioni di composizione. Il guardiano dichiara
come skill del giro soltanto commit/cycle/eval/exec: il suo controllo
comandi-permessi non certifica tutti i comandi di manutenzione.

Il validatore generico di skill-creator rifiuta il campo Claude
`user-invocable`, già presente prima della modifica; il campo resta per
preservare l'interfaccia Claude. La validazione generica completa non è
quindi dichiarata riuscita. Il wrapper Codex è invariato.

## Allineamento standby/production osservato il 26

Fonti: `remoto stato norvegia` e `remoto stato svezia` letti da `deck`
alle 08:57 del 2026-10-26, commit `e12f6c9`, `o3/modules/home/remoto/remoto.sh`.

- Standby: `norvegia` porta l'albero `9c9cca6` con la generazione home
  158 (2026-10-25 18:31); il giro delle 04:30 lo ha riallineato senza una
  nuova generazione e ha portato il checkout a `e12f6c9`, già su `origin`.
- Production: il custode ha lanciato `remoto allinea svezia --custode` da
  `deck`. Il gate «prima lo standby» è passato: generazione home 223 alle
  08:54 sullo stesso albero `9c9cca6`, checkout a `e12f6c9`, working tree
  pulito, nessuna unità di sistema o utente fallita. La home ha preso
  `nixpkgs` `3ec6363`, `ai` `3ec6363` e `home-manager` `c216bf5`; il
  sistema resta su `nixpkgs-work` `a7868a7`.
- La sequenza staging → switch standby → commit/push → checkout →
  production è quindi osservata a runtime, con l'esito dello switch e
  quello del checkout distinti nello stato remoto.
- Limite: il rifiuto con codice 8 (standby senza lo stesso albero) non è
  esercitato; per quel ramo vale solo la lettura del codice. L'output del
  comando lanciato dal custode non è conservato: l'esito si legge dallo
  stato remoto successivo.

## Diniego del giro del 26

Fonte: `i1/giri/ultimo.json` e trascrizione locale
`i1/giri/giri/6bc7860cbdf844ff80a89472c41c6a38.jsonl` (giro `e12f6c9`,
56 turni, `permission_denials: 1`).

- Comando negato, terza chiamata del giro:
  `wc -l autonomy.md o1/plan.md .claude/skills/{eval,exec,commit,manutenzione}/SKILL.md && grep -n "ciclo-autonomo" -A30 autonomy.md | head -80`.
- Ripiego: `Read` di `o1/plan.md` e di `o3/ciclo/permessi.json`, poi
  `grep -n -A25 "ciclo-autonomo" autonomy.md` e `sed -n`, passati. Il gesto
  non è abbandonato; il costo dichiarato è un turno.
- Il resoconto classifica il diniego come vincolo voluto («un pezzo non è
  concesso»). `o3/ciclo/permessi.json` concede però `wc *`, `grep *` e
  `head *`, e la prima chiamata del giro, con `;`, `&&` e `|`, è passata.
  L'unica forma assente dai comandi riusciti è l'espansione delle graffe:
  ipotesi di attrito dell'harness, non accertata senza una prova isolata
  dei pezzi nello stesso modo di permesso.
- Riscontro sul punto 1 della revisione: la classificazione scritta dal
  giro non ha confrontato il comando negato con i permessi letti subito
  dopo. La regola del passo 4 di `eval perceive` (classe del resoconto
  come ipotesi da rileggere) resta il presidio: il giro successivo deve
  rileggerla.

## Sessione del 26: revisione di un task

Il custode ha chiesto di valutare il task primo in coda, dopo domande
sull'allineamento di `svezia`. Sessione nuova, senza il resoconto del 25
nel contesto.

- `hostname` (deck) è stato il primo comando, con `git pull --ff-only`
  nella stessa chiamata: l'ordine host → pull → letture regge.
- Il task è stato raggiunto con `grep` del titolo su `o1`, `o2`, `i2`,
  `i3`, poi lettura di `o1/plan.md` e del file: non con plan → indice →
  task. Costo modesto (una chiamata), ma il percorso previsto non è quello
  seguito spontaneamente.
- Letture integre, nessun troncamento; valutazione e proposta separate
  dall'esecuzione, avviata solo dopo l'assenso del custode.
- Non esercitati: «qual è il prossimo task?» e `/exec all` sull'ingresso
  selettivo di `exec`.

## Esito del riesame congiunto (2026-10-26)

Il custode ha accolto la valutazione: la revisione si chiude, le verifiche
residue sono passive e restano al presidio di `eval perceive`, senza un
task ombrello in testa alla coda.

- Percorso 1 (task in sessione): campione del 26 sopra; ingresso
  selettivo di `exec` e «prossimo task» non collaudati, limite accettato.
- Percorso 2 (home-level): ricostruito sopra; il collaudo della
  ristrutturazione resta nel task di `/manutenzione`.
- Percorso 3 (standby/production): osservato il 26, codice 8 non
  esercitato.
- Dinieghi e cartelli (punti 1–2): classificazione al passo 4 di `eval
perceive`, con il caso del 26 da rileggere; le nuove lacune entrano nel
  task `o2/` del percorso o in un task nuovo.
- Criterio dell'albero (punto 3): deciso il 2026-10-25, conservato in
  `kb/cicli.md`.
- Deriva della home (punto 4): `home-drift.sh` usato nel giro del 26 su
  `deck` e `norvegia`, ha segnalato la deriva reale di `svezia`, poi
  risolta dal custode.
- Registro di manutenzione (punto 5): `registro.sh` usato nei giri del 25
  e del 26 e in questa sessione, senza ripieghi Python osservati.
- Il conteggio dei tre giri puliti non è attestato e non è più condizione
  di chiusura: limite accettato dal custode.

Connessioni:

- [agent-as-user](../method/agent-as-user.md)
- [agent-task-orientation-20261024](agent-task-orientation-20261024.md)
- [cicli](../kb/cicli.md)
