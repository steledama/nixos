# plan — la coda

**1. Raccogli il contesto corrente**

Esegui in parallelo:

```bash
git diff HEAD
git status --short
git log --oneline -5
```

Leggi `o1/plan.md`, il register `goal.md`, `world.md`, i fili in `i3/` e i file
`o2/` necessari per capire i task aperti. Se l'obiettivo è solo un health
check, puoi limitarti ai titoli/frontmatter dei file `o2/`.

Cerca gli **handoff pendenti**: gli «impatti sul piano» di un `eval compare`
appena girato e le catture `i1/` con impatti o1 non ancora consumate. Sono
input, non comandi: consumali con giudizio e dichiara le divergenze (es. una
dipendenza che resta `world` sulla issue upstream anche se il workaround
locale è già stato verificato).

**2. Verifica la consistenza o1↔o2 col generatore**

Il contratto plan×`o2/` lo verifica il generatore: esegui
`python3 method/../o3/view/build.py --root . --check` e interpretane l'esito — a contratto violato
esce con l'elenco degli errori (file `o2/` senza riga del plan, voce di
`o2/tasks.md` senza file, file non indicizzato, ciclo divergente fra plan e
frontmatter, colonna `Ob.` vuota o che punta a un obiettivo assente dal
register). Una riga semplice del plan può non avere un dettaglio `o2/`: il
file serve quando occorre contesto. Non reimplementare il matching a mano. Resta al giudizio ciò che il
generatore non copre:

- le prescrizioni in `o3/prescriptions.md` collegate a lavoro chiuso non
  restano in collezione — il dettaglio è giurisdizione di `perform`, qui basta
  il rimando
- task tecnici completati da un commit, un rebuild o un cambio di
  configurazione non restano aperti
- prima di chiudere un task, enumera le sue materializzazioni note sulle
  superfici dichiarate in `world.md`, usando il file `o2/` e l'eventuale
  prescrizione `o3/` come mappa primaria; applica il test del significato senza
  artefatto (`method/world.md`): effetti ed evidenze durevoli restano, copie
  operative consumate sono candidate alla pulizia. Non scandire genericamente
  il Mondo e non inferire autorità: senza target esatto e autorizzazione
  esplicita proponi la rimozione e fermati alla membrana
- task senza file `o2/` sono accettabili solo se intenzionalmente leggeri
- `## Direzione` si confronta con Goal, fili e coda a ogni giro: si riscrive
  solo se cambiano traguardo, fase operativa o rotta; avanzamenti e prossimi
  passi restano nei task. La fase dichiarata non si deduce dal numero di righe
  della tabella: quantità di task e ricorrenze sono indizi, non una prova
  di maturità (`method/plan.md`)
- **direzione task→obiettivo**: la colonna `Ob.` la verifica il generatore
  contro le chiavi di `goal.md`; qui resta il giudizio sul fatto che la chiave
  sia quella _giusta_ — un task che non serve davvero l'obiettivo che dichiara
  è un candidato al taglio. La direzione opposta (obiettivo→segnale/filo) è di
  `eval compare`
- lancia `python3 method/../o3/scadenze.py` (`method/plan.md`, «Ricorrenze»):
  catena a 45 giorni, attese a finestra, `by:` passati e rilievi di forma. Non
  rifare a mano il confronto delle date. L'uscita 1 dice che c'è una scaduta:
  si tratta qui e non ferma il commit. Un rilievo di forma si corregge nel
  plan. Se il checkout del canone manca sull'host, il giro lo dice in
  `Attenzione:` e non salta il controllo in silenzio
- `## Ricorrenze` (`method/plan.md`, «Ricorrenze»): una riga `task` arrivata
  alla data apre il task ordinario e avanza; una riga `sessione` dovuta va in
  `Attenzione:` nel giro senza custode; una riga senza procedura è un rilievo.
  Non sono candidate al `Prossimo:`
- `## Scadenze` e finestre tattiche: righe scadute o consumate. Una scadenza che chiede una mossa nostra prima della
  data ha il task che la prepara: la riga «entro…» senza task è un rilievo, e
  il giro crea il task perché la pianificazione è delegata (`method/plan.md`,
  «Tempo e fonti»)
- risveglio delle attese (`method/plan.md`, «Risveglio»): ogni `w` dichiara
  `probe:` o `arrival:`, ogni `w` e ogni `p` dichiara `by:`; una chiosa senza
  è un rilievo da correggere. Le righe `RIESAME` di `scadenze.py` sono i
  `by:` passati

**3. Rivaluta stato, dipendenze e priorità**

Individua eventi che possono spostare priorità o creare/rimuovere dipendenze,
che in NixOS hanno natura propria:

- rebuild o reboot eseguito -> può sbloccare o chiudere task di monitoraggio
- modifica a `o3/hosts/`, `o3/modules/`, `o3/home/` o `flake.*` -> può creare
  verifiche successive
- cambio di ruolo di un host o di un servizio -> può alzare priorità operativa
- issue upstream chiusa o fix rilasciato -> scioglie una dipendenza `world`
- il segnale che riapre una riga `w` è comparso fra le catture -> la riga
  risale fra le pronte e il `Prossimo:` cambia con quel segnale per causa;
  una riga `p` che aspetta solo un'occorrenza del Mondo passa a `w` col suo
  segnale (`method/plan.md`)
- il `by:` di una `w` o di una `p` è passato -> sollecitare (per la `p`,
  riprendere), riclassificare o rinnovare il termine col motivo nella
  chiosa; nel giro senza custode la riga va in `Attenzione:`
- nuova informazione hardware/rete/segreti -> può aprire task locale o
  aggiornare `world.md`

Verifica se `world.md`, i nodi tecnici o il filesystem indicano lavoro futuro
non tracciato.

**3b. Lettura strategica delle mosse**

L'igiene (passi 2-3) dice se la coda è coerente; non se una mossa **vada
fatta**. Per ogni mossa nostra interroga tre lenti — se una si accende, la
mossa può **nascere come pausa** invece che come prossimo task:

- **mandato/canale** — la mossa scavalca un canale con mandato? In NixOS:
  modificare un nodo di canone via symlink `method/` invece di segnalarlo e
  lasciarlo ratificare a `method` («agisci attraverso, ratifica»); o un rebuild
  su `deck`, capogruppo e gateway delle VPN, prima di averlo collaudato su un
  host meno esposto.
- **sequenza/informazione** — un reboot o un test imminente darebbe un _read_
  prima di muoverci? In NixOS: attendere l'esito del boot di un host prima di
  propagare un pin o un cambio kernel agli altri.
- **effetti di secondo ordine** — la mossa rompe uno stato condiviso o un altro
  host? In NixOS: un cambio in `o3/modules/` o `flake.*` che rompe il boot
  altrove, o un refactor che rompe un generatore.

È la versione **plan-time** del check i3 che `/commit` fa a commit-time:
stesso invariante, momento diverso.

**3c. Visione d'insieme**

Il giro parte a freddo e guarda soprattutto il delta: ciò che si ripete,
ciò che è fermo e ciò che scade fra settimane gli sfugge (`method/tasks.md`,
«Task e giro»). Rileggi anche la finestra larga:

- **giri della settimana**: i corpi dei commit dei giri degli ultimi 7
  giorni (`git log --since='7 days ago' --grep='^docs(ciclo)' --format='%h %ad%n%b' --date=short`).
  Servono i corpi: con `%s` restano gli oggetti e le voci da contare non si
  vedono (4 giri su 10 in quattro repo, novembre 2026). Una voce per il custode, un'anomalia, un'ipotesi o un'esclusione fatta a
  mano che torna in tre giri senza esito sale in `Attenzione:`, oppure
  diventa un passo di task o una regola: non si ripete identica un altro
  giorno. La conferma del `Prossimo:` con esiti sani non conta: è
  l'equilibrio
- **decisioni ferme**: un task con `decidere:`, o con un passo che aspetta il
  custode, fermo da più di 7 giorni va in `Attenzione:` coi giorni di attesa
- **catena delle scadenze** a 45 giorni, dall'uscita di `scadenze.py` del passo 2, letta come sequenza: un anello senza
  task o senza data è un rilievo del passo 2
- **canali delle attese**: un `arrival:` da un canale che il giro non legge
  per un permesso o uno strumento mancante non si rinnova in silenzio: è una
  lacuna da proporre (`method/plan.md`, «Risveglio»)
- **tendenze**: in NixOS i segnali ricorrenti sono le derive di sistema e
  home, le unità fallite, le versioni rimaste indietro in `/manutenzione` e i
  dinieghi dei giri; leggi la serie delle ultime due settimane, non il giorno

Ciò che la finestra larga trova entra nel passo 4 come ogni altro fatto,
risalendo la catena (`method/action-cycle.md`).

**4. Applica entro la delega e indica il prossimo task**

Rendi leggibili le modifiche applicate e le proposte pendenti — una voce per task,
con azione (aggiungi/modifica/rimuovi), priorità e motivo:

- **<task>** — <azione>; priorità <…>; <motivo>

Se non ci sono modifiche da proporre, dillo esplicitamente. Chiudi indicando
il task consigliato. Di norma è la prima riga pronta del plan (`Dip.` a `—`),
perché l'ordine delle righe è l'ordine di esecuzione: il riesame parte dalla
coda, non dal giro precedente. Una sessione può aver messo una riga in testa
senza toccare il trailer. Se consigli un'altra riga, il corpo del commit
nomina quella scavalcata e il motivo (urgenza, costo/opportunità, una lente
del passo 3b). Poi confronta il consigliato con l'ultimo trailer `Prossimo:`
della storia (la riga `Prossimo:` di `python3 method/../o3/ultimo_giro.py`;
senza trailer precedente è un cambio, con causa «primo trailer»):

- **confermato**: dì in una riga, nel corpo del commit e nel resoconto,
  cosa hai riesaminato contro la coda e perché regge; il trailer resta
  `(confermato)`. Una conferma ripetuta per molti giri non è un'anomalia:
  senza notizie che muovano la coda e con esiti runtime sani è l'equilibrio
  (`method/plan.md`);
- **cambiato**: nomina il task precedente e la causa, risalendo la catena
  fino al punto che l'ha mossa (percezione nuova, ipotesi smentita o
  confermata in `i2/`, verdetto di un filo, obiettivo corretto in
  `goal.md`, dipendenza sciolta). Un cambio senza causa nominata è un
  riordino arbitrario.

Lo stesso obbligo vale per ogni modifica a `o1/plan.md` e `o2/` mossa da un
fatto nuovo, non solo per il `Prossimo:`: una specifica corretta, un'attesa
chiusa, un task creato o cancellato nominano lettura e verdetto che li hanno
mossi (`method/action-cycle.md`, «Risalire prima di scendere»). Se un fatto
di `i1/` sembra chiedere la modifica ma nessuna lettura né verdetto lo
copre, la modifica aspetta: prima si scrive l'anello mancante, rimandando a
`eval`.

Il trailer `Prossimo:` va nel commit che chiude il giro. `commit_gate.py
dopo` avvisa se scavalca la prima riga pronta: prima del push, un corpo che
non nomina la riga scavalcata e il motivo si corregge. Applica a `o1/plan.md` e `o2/` entro la delega del gate
comune; chiedi solo sui punti che ne superano il confine. Nel ciclo autonomo
il plan si muove sulle notizie del giro, senza eseguire i task
(`method/tasks.md`, «Task e giro»).

**5. Chiudi con l'handoff inverso «verdetti da rivalutare»**

Task i cui fatti, visti dal versante esecuzione, smentiscono o incrinano un
filo `i3/` (un esito di rebuild o di boot, una issue upstream chiusa, un drift
di `facts`/`fidelity` che il filo non registra). Se il protocollo post-evento è
stato rispettato l'elenco è normalmente **vuoto** — il vuoto è il segnale che
la verità è passata per prima, non un fallimento. Se non è vuoto, segnalalo al
custode: il movimento di ritorno è l'eccezione che va giustificata, non un
secondo giro automatico.

Minimo: `o1/plan.md`, `goal.md`, l'ultimo trailer `Prossimo:`, i corpi dei
giri della settimana del passo 3c, verificati da `commit_gate.py stadi`, e
`python3 method/../o3/view/build.py --root . --check`.

## Convenzioni della coda

- Mantieni i titoli brevi e coerenti con la tabella esistente
- La colonna `Dip.` deve riflettere dipendenze reali, non preferenze d'ordine;
  `w<n>` per le attese esterne (upstream) e `p<n>` per le pause nostre, con voce
  in legenda nello stesso ordine della tabella (`method/plan.md`); la build si
  ferma su una chiave senza voce
- La colonna `Ob.` porta il numero dell'obiettivo di `goal.md` che il task
  serve, `S` per il Goal di sviluppo: una cella vuota non è ammessa
- I task completati si rimuovono da `o1/plan.md` e `o2/`; lo storico resta in
  git, nei fili `i3/` e nei nodi aggiornati. La chiusura toglie anche i
  rimandi che il repo tiene al task (`method/tasks.md`): la chiosa `w`/`p`
  della legenda, che `build.py --check` verifica, e in `i1/manutenzione.json`
  la voce `world.<titolo>` e i campi `promosso` che lo nominano
  (`/manutenzione`, `chiusura.md`; il prospetto li segnala come orfani)
- La chiusura di un task coordina l'eventuale prescrizione `o3/` con i documenti
  operativi che ha prodotto nel Mondo: `perform` tiene onesta la collezione,
  `plan` controlla che non restino copie consumate sulle superfici dichiarate

## Trailer del prossimo task

Un giro che invoca `plan` registra nello stesso commit anche il prossimo task
(passo 4 di `plan`), con il titolo della riga del plan:

```
Prossimo: <task> (confermato)
Prossimo: <task> (cambiato, era <task>; <causa in poche parole>)
Prossimo: nessuno (<motivo>)
```
