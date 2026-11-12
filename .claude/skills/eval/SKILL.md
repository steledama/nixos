---
name: eval
description:
  Il braccio di valutazione del ciclo — eval [perceive|interpret|compare|all] —
  raccolta del grezzo dal sistema in esecuzione, sintesi i2 con provenienza e
  cascata, verdetto dei fili i3 contro goal.md e bonifica del plan
user-invocable: true
---

Compi il braccio di valutazione del ciclo, nell'ordine degli stadi:
`perceive` → `interpret` → `compare`. L'argomento seleziona lo stadio, il
default è `all` (la sequenza intera). Ogni stadio invocato restituisce un
esito esplicito e può **chiudere in una riga** quando non ha materia («nessun
segnale nuovo»): la chiusura vuota è esito legittimo, non un passo saltato.

L'esito di ogni stadio invocato si registra nel commit che chiude il giro, con
un trailer contabile (`materia` se lo stadio ha prodotto o cambiato qualcosa,
`vuoto` se ha chiuso in una riga; gli stadi non invocati non compaiono):

```
Esiti: perceive=vuoto interpret=materia compare=materia
```

`vuoto` vuol dire che lo stadio ha girato, col suo **minimo**, e non ha
trovato materia; uno stadio saltato non è `vuoto`, resta fuori dal trailer.
Una riga che registra solo il giro stesso (un marker, un cursore, il conto di
una lettura che non sposta) non è materia: lo stadio resta `vuoto` (giro del
2026-11-08). Il minimo di ogni stadio, scritto in fondo alla sua sezione, sono le letture
che lasciano traccia nella trascrizione; un adottante lo adatta nel prompt
del ciclo aggiungendo i gesti del dominio, senza toglierne (caso `nixos` del
2026-11-07: per venti giorni sei stadi dichiarati, `goal.md` mai letto).

Un giro senza file cambiati, quando il commit è chiesto, lo chiude `/commit`
con `--allow-empty` e lo stesso trailer: il giro tutto vuoto è proprio quello che la misura deve
contare. Il conteggio è
`git log --format='%(trailers:key=Esiti,valueonly)'` (`method/skill.md`).

È la skill simmetrica di `exec`: questa tiene onesta la valutazione, quella
l'esecuzione; il register `goal.md` è la cerniera che entrambe controllano da
versanti opposti. Usala quando un giro del ciclo produce esiti (un rebuild
verificato, un workaround rimosso, una diagnosi falsificata, un verdetto
ratificato), a inizio sessione strategica, o quando fili e note sembrano
crescere senza controllo. Dopo eventi del mondo vale il **protocollo
post-evento**: `eval` → `exec` — la verità prima delle priorità; un rebuild o
un boot appena osservato va prima letto come verità, poi come priorità.

**Gate comune, autorità prima dell'atto**: leggere `autonomy.md` insieme
alle autorizzazioni operative di `CLAUDE.md` e alla richiesta corrente. Nel
ciclo delegato dal custode si applicano gli esiti ordinari senza conferme
intermedie, con fonti verificate e incertezza esplicita. Restano al custode
cambi di scopi, territorio o criteri di autonomia, atti fuori delega — in
NixOS ogni `sudo`, rebuild, reboot e atto su host diversi dal locale — e
incertezze decisive non risolvibili dalle fonti. Sospendere il solo punto
che richiede una decisione e continuare il lavoro indipendente. In assenza
di delega applicabile si propone; il colore dell'impatto non concede autorità.

Chiudere gli scope richiesti con i controlli, l'esito per stadio e la
proposta di commit. Questa skill è una base e non chiama altre skill
(`method/skill-composition.md`): commit e push del branch corrente, nei
limiti di `CLAUDE.md`, li compie `/commit` quando li chiede il custode o la
composta `/cycle`, e ne scrive i trailer dagli esiti ricevuti. Nella sessione interattiva il momento del commit si
concorda col custode (`autonomy.md`, `momento-del-commit`): un ciclo chiesto
fino al commit lo include, gli scambi successivi no. Nel ciclo congiunto
l'ordine è `eval → exec → commit`,
senza conferme obbligatorie fra gli archi; invocare un arco solo non estende
lo scope. Il resoconto finale distingue decisioni applicate in autonomia,
conferme richieste, punti sospesi e proposte pendenti, con i motivi. La
presenza del custode non equivale alla ratifica di ogni modifica; i trailer
seguono chi l'ha decisa.

## `perceive` — raccogliere il grezzo

Valenza-neutro: qui si cattura il segnale. Il confine i1→i2 è l'attribuzione di
significato; il giudizio rispetto al Goal entra in Compare (i3). Anche
l'interpretazione sospende la valenza, distinguendo spiegazione e verdetto.

1. Raccogli ciò che arriva dal Mondo. In NixOS i canali sono: il sistema in
   esecuzione letto attraverso la membrana `world -> /run/current-system`
   (host-local, gitignorata, a materializzazione facoltativa), gli esiti di
   rebuild e di boot, lo stato delle issue upstream citate come dipendenze
   `world` nel plan, la diagnosi degli update (la fase in sola lettura di
   `/manutenzione`; i suoi atti stanno in `perform`), gli esiti già prodotti da `/kb`
   (`kb_tools.py audit` / `facts` / `fidelity`, capacità trasversale ai due
   archi), i segnali che il custode porta da un altro host. Confronta i fatti
   in ingresso con le `w` ad `arrival:` del plan, usando il canale dichiarato
   come mappa della ricerca; l'esito delle `probe:` lo legge dal ramo world
   di `/manutenzione` (`method/plan.md`, «Risveglio»).
2. Cattura in `i1/` (item più voce in `i1/perceptions.md`) **solo** ciò che è
   effimero o che per precisione e durata chiede un riflesso stabile (cfr.
   `method/perceive.md`). Qui vale una divergenza dichiarata: il grezzo di
   NixOS è persistente e interrogabile — il sistema in esecuzione, `nix eval`,
   il git log — quindi `i1/` resta col solo indice finché una cattura reale non
   richiede precisione o durata. Nel ciclo delegato la lettura degli altri
   host via `ssh` è ammessa in sola lettura e senza `sudo` (`autonomy.md`,
   «Perimetro NixOS sul Mondo»).
3. **Casi della delega**: se nell'uso è emerso un caso metodologico — un
   confine ambiguo, un arresto, un errore di ricostruzione, un criterio che
   non bastava, ma anche un'autonomia riuscita con riscontro o una conferma
   rivelatasi inutile — catturalo in `i1/` con i cinque elementi (situazione,
   confine, comportamento, riscontro, questione per il metodo) e la voce
   nell'indice con stato «da inoltrare» o «acquisita da method». La consegna a
   `method` avviene in una sessione autorizzata sul canone
   (`method/method-development.md`); senza, il caso resta locale e l'handoff
   pendente si dichiara nel resoconto. Nessun caso va prodotto solo per
   completare il giro.
4. Leggi l'ultima chiusura del ciclo autonomo con `giro` non nullo in
   `i1/giri/tentativi.jsonl` (esito, costo, durata, `dinieghi`): un arresto
   chiude senza trascrizione né dinieghi e non copre il giro che lo precede.
   Apri la trascrizione solo per il dettaglio. Ogni diniego si classifica,
   per il contesto del giro, come vincolo voluto, lacuna o attrito
   dell'harness (`method/agent-as-user.md`), dopo averne accertato la causa: il comando
   negato si confronta col tentativo riuscito che lo segue nella
   trascrizione, e la differenza fra i due è la causa; senza un tentativo
   riuscito la causa resta un'ipotesi dichiarata. Un gesto legittimo
   abbandonato dopo il diniego vale come lacuna probabile finché una prova
   isolata, coi pezzi del comando lanciati uno per volta, non ne accerta la
   causa. La classe scritta nel resoconto del giro è un'ipotesi da
   rileggere sulla trascrizione, non un fatto. In ogni caso: il vincolo
   voluto è un fatto del giro, l'attrito si registra col suo costo in turni,
   la lacuna diventa una proposta nel task `o2/` del percorso
   attraversato, o in un task nuovo se nessuno lo copre, da chiudere col custode
   sul permesso o con uno script consentito, mai con un'istruzione che chiede
   di aggirarla.
   Sulla stessa chiusura lancia `python3 method/../o3/commit_gate.py stadi`:
   gli stadi che l'`Esiti:` del giro precedente dichiara senza la traccia del
   loro minimo vanno nella riga `Attenzione:` di questo giro; un suo
   `avviso` su fili e obiettivi non nominati va nell'autovalutazione. Poi riprendi
   la riga `Attenzione:` del resoconto precedente voce per voce: risolta,
   invariata o cambiata; una voce lasciata «non indagata» si indaga qui
   (cfr. `cycle`, «Resoconto finale»).
5. Per ogni cattura in `i1/` con una soglia di promozione, conta i casi
   dalla fonte che dichiara e, raggiunta la soglia, compi la promozione
   dichiarata. Una soglia non contabile si riscrive con N, M e la fonte se
   i casi la danno; altrimenti diventa una proposta (`method/perceive.md`).
6. Esito: cosa è entrato, cosa è stato catturato e perché, cosa resta fuori.

Minimo: i canali del passo 1; nel ciclo autonomo anche il passo 4, con la
verifica degli stadi del giro precedente e la sua riga `Attenzione:`.

## `interpret` — distillare in sintesi

Orientato dai goal sulla rilevanza, neutro sulla valenza (cfr.
`method/goal.md`). Le sintesi sono raggiungibili da `i2/interpretations.md`;
il deck `presentation/presentation.md` racconta l'artefatto e rimanda alle
letture presidiate. Una nuova sintesi nasce in `i2/`. Tre obblighi:

- **Provenienza delle quantità** (cfr. `method/verdict.md`): un numero che
  entra in una sintesi dichiara se è misurato, dichiarato da terzi o derivato
  da dichiarazioni. In NixOS le quantità sono versioni di pacchetti, misure di
  sistema, tempi di rebuild, dimensioni di closure: una versione letta da
  `nix eval` sul sistema che gira è misurata, una letta da un changelog
  upstream è dichiarata da terzi, una stima di impatto è derivata — e una
  quantità derivata non fa da architrave.
- **Cascata all'indietro**: quando un claim cambia o cade, cerca le sintesi
  `i2/` e i nodi `kb/` che lo usavano e correggili — prima i riferimenti
  espliciti, poi i candidati semantici da verificare. Il riconoscimento di
  ogni dipendenza implicita non si promette: ciò che non è stato verificato si
  dichiara.
- **Materiale di casa prima**: il file `o2/`, il nodo `kb/` di dominio e
  l'aggregato `fidelity` vanno letti prima della nuova sintesi. Sono evidenza
  di ciò che il progetto ha deciso, scritto o valutato; non provano da soli i
  fatti esterni che riportano — eccezione fatta per la configurazione
  dichiarativa in `o3/`, che per NixOS è essa stessa la fonte di verità sul
  sistema: una sintesi che la contraddice ha torto lei.

**Ipotesi in attesa** (cfr. `method/interpret.md`): leggi l'indice `i2/`, i fili
raggiunti da `i3/verdicts.md`, le `## Scadenze` e le `## Ricorrenze` di `o1/plan.md`, seguendo i
rimandi alle ipotesi anche quando non ci sono segnali nuovi. Ogni ipotesi in
attesa dichiara orizzonte e riscontro con fonte: verifica se l'evento o il
riesame è arrivato, confronta il riscontro disponibile con il criterio e
riporta le correzioni nelle letture dipendenti. Distingui dati mancanti,
riesame scaduto e ipotesi risolta. Proponi il presidio dove manca; un filo
con criterio, conteggio e data può già bastare. Non introdurre facet,
contenitori o ipotesi per completare una collezione vuota. Dichiara quali
ipotesi hai riesaminato e ciò che resta non verificato.

**Lettura che non sposta** (cfr. `method/interpret.md`): un riesame che non
conferma né smentisce l'ipotesi e non ne cambia costo, orizzonte o riscontro
non aggiunge una frase: aggiorna il conto, N casi su M letture, e il rimando
alla cattura dell'ultima lettura. Nel presidio restano i casi che hanno mosso
l'ipotesi, la prima e l'ultima cattura e il conto; la cronaca vive nelle
catture `i1/` e nella storia Git. Un presidio cresciuto a cronaca si
ricompatta al primo giro che lo tocca, portando a conto le letture che non
l'hanno mosso; la soglia di righe che lo segnala è un parametro locale
dell'adottante. Il riesame si dichiara comunque nell'esito dello stadio.

**Ipotesi formate nel giro** (cfr. `method/interpret.md`): rileggi ciò che il
giro ha scritto o toccato, in qualunque file e nel messaggio di commit che
stai preparando, cercando la forma, non l'intenzione: un «perché», un
«quindi», una previsione, una generalizzazione da pochi casi. La forma
segnala un candidato; la prova è se l'affermazione va oltre i dati. Un
«quindi» che è aritmetica su misure è una **derivazione**: resta dov'è e
dichiara la provenienza «derivato» (`method/verdict.md`). Un «quindi» o un
«perché» che aggiunge un'assunzione è un'**ipotesi**: portala nel presidio —
la sintesi `i2/` pertinente o un filo
`i3/` con criterio; nixos non tiene un registro delle ipotesi separato — con
affermazione, provenienza, cosa la smentirebbe e orizzonte. Un task `o2/`
porta il lavoro: può rimandare a un'ipotesi, non ospitarla. Le ipotesi già
scritte nei file toccati si trattano allo stesso modo: emergono quando un
giro ci passa, senza spazzate dell'archivio. Un'ipotesi smentita si cita e si segna smentita,
con il dato che la smentisce; non si riscrive in silenzio. Un giro che forma,
conferma o smentisce un'ipotesi registra `interpret=materia`, anche se il
testo nasce altrove.

Esito: quali sintesi sono nate o cambiate, contro quale materiale sono state
verificate, quali ipotesi sono nate, confermate o smentite, quali
affermazioni restano non verificate e sono dichiarate tali.

Minimo: le sintesi `i2/` che le notizie del giro toccano, o l'indice di
`i2/` quando non ne toccano nessuna, e la rilettura delle ipotesi formate nel
giro.

## `compare` — il verdetto contro il Goal

**1. Raccogli il contesto corrente**

Leggi `goal.md`, `i3/verdicts.md` e ogni filo `i3/*.md`; poi `o1/plan.md`,
`world.md` e gli eventi dall'ultimo giro: `python3 method/../o3/ultimo_giro.py`
dà il commit, `git log --oneline <commit>..HEAD` gli eventi, tutti. Una
finestra a numero fisso perde il lavoro del custode fra due giri (2026-11-08:
35 commit contro `-15`). Senza un giro precedente vale la data dell'ultima
revisione, con `--since`. In
NixOS i segnali reali sono l'audit e l'aggregato drift (`python3
method/../o3/kb_tools.py --root . audit` / `facts` / `fidelity`), lo stato del sistema in
esecuzione (membrana `world -> /run/current-system`, esiti di rebuild e boot),
lo stato delle issue upstream citate come dipendenze `world` nel plan, gli
esiti di `perceive` e `interpret` di questo giro e le percezioni `i1/` non
ancora valutate.

**2. Cinque domande per ogni filo**

- **È ancora vero?** Confronta il verdetto col segnale reale (audit, runtime,
  issue upstream), non con la memoria. Un filo che contraddice il suo segnale
  va aggiornato in place prima di ogni altra cosa. Fra i segnali c'è il **file
  `o2/` che alimenta il filo**: `exec plan` guarda plan↔`o2/`, questo stadio
  guarda filo↔segnali, e filo↔`o2/` non è di nessun altro — è spesso la
  registrazione più fresca e più cauta, e il filo che è più ottimista del
  proprio task ha già in casa la propria smentita (`method/verdict.md`).
- **È più sicuro del suo materiale?** Sul filo che suona meglio degli altri —
  più elegante, più quantificato, più favorevole — fai un passo in più, non uno
  in meno: le quantità che reggono la tesi portano la provenienza (misurata sul
  sistema che gira / dichiarata dall'upstream / derivata da stime)? Ciò che il
  progetto ha prodotto **di suo** (la configurazione dichiarativa in `o3/`, il
  nodo `kb/` di dominio, il file `o2/`, l'aggregato `facts`/`fidelity`) è stato
  guardato? Un verdetto che dichiara risolto un difetto sulla base di un fix
  upstream annunciato — e non di una verifica runtime locale — non è un
  verdetto: è una congettura da retrocedere.
- **È ancora aperto?** Verdetto stabile, nessuna tensione e nessuna altra
  funzione viva → il filo si chiude: file rimosso, voce tolta da
  `i3/verdicts.md`, storia in git. I file che custodiscono cursori o contratti
  correnti restano (`i3/allineamento-metodo.md` è governato da `/method`).
  Prima di rimuovere un filo che custodisce un'ipotesi in attesa, conserva
  orizzonte e riscontro con fonte in una destinazione esplicita raggiungibile
  da `eval`. La chiusura operativa non conferma da sola una spiegazione.
- **È ancora _un_ filo?** Se è cresciuto multi-tema, proponi lo split; ogni
  filo tiene una tensione sola.
- **È stato, non log?** Pota paragrafi storici e sequenze datate: la cronologia
  è il git history del file, non il suo corpo. Un segnale continuo riporta il
  conto, la prima e l'ultima cattura e le sole letture che hanno mosso il
  giudizio, non una frase o un link per giro (`method/compare.md`).

**3. Copertura bidirezionale con `goal.md`**

- Ogni obiettivo del register ha un **segnale vivo** (filo, audit, fidelity,
  esito runtime) e — se c'è tensione aperta — un filo che la tiene. Un
  obiettivo senza segnale è un buco di misura da dichiarare nel register, non
  da nascondere. Il register punta al segnale; esito e stato del lavoro
  restano nei fili e nel plan.
- Ogni filo dichiara **quale obiettivo misura** (`obiettivo:` nel
  frontmatter, chiave di `goal.md`: `1`, `2`, `3`, `S`; verificato dalla
  build). Un filo che non misura nessun obiettivo è materiale da triage: o
  rivela un obiettivo mancante nel register (proponilo), o non è un verdetto —
  motivazione stabile da portare nel nodo, ipotesi in attesa da mantenere
  raggiungibili con orizzonte e riscontro con fonte nel nodo o nella lettura
  pertinente, decisione da prendere da affidare a un task `o2/`
  (`method/verdict.md`, «Che cosa è un filo»). Non confondere la provenienza
  del segnale con l'obiettivo misurato, e non tenere aperto un filo che
  aspetta «il primo caso reale» senza data né conteggio.
- Segnali orfani (percezioni `i1/` che nessun filo valuta, drift di fidelity
  che nessun filo tiene) vanno fatti emergere.

**4. Bonifica del plan (e dei task)**

Il plan è coda pura: tabella, dipendenze, legenda. Note e «cause» che sono
narrativa di stato del mondo (diagnosi, esiti di boot, posizioni) migrano nel
filo pertinente — o nel task `o2/` se sono contesto operativo di esecuzione.
Stessa lente sui task `o2/`: i diari di sessione si potano a chiusura. È il
gemello del passo «igiene» di `exec plan`, guardato dal versante opposto.

Lancia `python3 method/../o3/scadenze.py` (`method/plan.md`, «Ricorrenze»): una
riga `saltata` più volte, o che da molte occorrenze non produce niente, è
candidata a una cadenza più bassa o al taglio. Il numero fra parentesi dice
quante occorrenze ha perso; il taglio resta una proposta.

Migrare è **fondere, non cancellare**: prima di potare una copia, stabilisci
quale delle due porta il fatto più fresco. L'assunzione naturale — la copia è
stale, la destinazione è vera — non regge sempre: spesso il plan porta l'esito
di un rebuild o di una issue upstream più recente del filo, e potare alla
cieca distruggerebbe informazione.

Fondere guarda anche ai **lettori**, non solo al contenuto: chiedersi chi altro
legge la copia che stai rimuovendo, macchine incluse. Qui il footer
`## Dettagli task` di `o1/plan.md` era un secondo indice per l'umano ma l'unica
chiave con cui l'allora `o3/presentation/build_views.py` risolveva una riga del plan al suo
`o2/`: potato il footer, `presentation/tasks.html` è rimasto fermo al
2026-07-10 mentre il generatore rendeva il vuoto, senza che nulla rompesse
(cfr. `method/view.md`, «Derivata implica verificata»).

**5. Formazione goal (modo due dell'i3)**

Input esogeni che non chiudono loop noti ma ne aprono di nuovi (un segnale
runtime che non rientra in nessun obiettivo, un cambio di esigenza degli host,
una cornice importata da `method`) → proponi il filo nuovo o il ritocco al
register. Sempre in proposta: decidere cosa conta è del custode
(`method/goal.md`).

**6. Applica entro la delega, proponi oltre il confine**

Per ogni filo/obiettivo rendi leggibili azione (aggiorna/chiudi/split/crea,
migra dal plan) e motivo. Il resoconto del giro ne porta la traccia, una riga
per ogni filo con `obiettivo:` e una per ogni obiettivo del register:
`<nome del file del filo>: <regge, aggiornato, chiuso> (<segnale usato>)` e
`obiettivo N: <segnale vivo o buco di misura>`. Il segnale è un path, uno SHA
o una data col suo canale; la memoria del giro precedente non è un segnale.
Applica gli esiti autorizzati dal gate comune;
porta al custode soltanto i punti riservati, con una proposta concreta e
raggiungibile. Distingui nel resoconto modifiche applicate e decisioni
pendenti. Se non c'è materia, dichiaralo e chiudi secondo il gate comune.

**7. Handoff «impatti sul piano»**

Elenco puntato, non eseguito: ogni verdetto cambiato in questo giro che
implica modifiche a `o1/plan.md`/`o2/` (priorità, dipendenze `world` sciolte
da una issue upstream chiusa, scadenze, task superati da un rebuild), come
input per l'`exec plan` a valle. Ogni voce nomina il verdetto e la lettura
che l'hanno mossa (`method/action-cycle.md`, «Risalire prima di scendere»).
Un fatto di `i1/` che sembra chiedere una modifica al piano senza che un
verdetto lo copra non passa come impatto: prima si chiede quale lettura lo
spiega e quale verdetto cambia, e si scrive l'anello mancante. L'handoff è
input, non comando: lo scope
ricevente conserva il giudizio e dichiara le divergenze. Se non c'è nulla da
passare, dillo esplicitamente.

Minimo: `goal.md`, `i3/verdicts.md` e ogni filo `i3/*.md`, ciascuno almeno
alla domanda «è ancora vero?» contro i segnali del giro. Il minimo misura la
lettura: la traccia del passo 6 rende controllabile il giudizio, e
`commit_gate.py stadi` avvisa se un filo o un obiettivo non è nominato.
Nominarli non prova che il giudizio regga: quello resta ai riesami a campione
(`autonomy.md`, «Errori e supervisione»).

## Note operative

- I fili chiusi si rimuovono, non si archiviano: la storia resta in git.
- Il frontmatter dei fili tiene `ciclo` e `obiettivo`; l'indice
  `i3/verdicts.md` non li ripete.
- La valutazione non cambia mai un segnale (audit, runtime): se il segnale è
  sbagliato, il fix è un task, non un ritocco al verdetto.
- Il register `goal.md` conserva il nord e i puntatori ai segnali. In questa
  sede se ne verifica la copertura: correggere puntatori o dichiarare un buco
  di misura segue il gate comune; esiti, misure e stato del lavoro restano
  nelle fonti, nei fili e nel plan. Nuovi obiettivi o cambi del nord tornano
  al custode.
- Nessuno stadio di questo arco esegue rebuild o comandi `sudo`: la
  valutazione legge il sistema, non lo cambia.
