---
name: kb
description: Audit strutturale e quantitativo o revisione semantica della knowledge base.
user-invocable: true
---

# kb

Usa `/kb [audit|review]` dalla root del repository; default `audit`.

- `audit`: profilo quantitativo e controlli deterministici, senza correzioni;
- `review`: audit seguito da lettura integrale, verifica delle affermazioni
  selezionate per rilevanza e giudizio sull'utilità della conoscenza.

Leggi prima [domain.md](domain.md), il profilo del repository: dichiara fonti,
comandi, convenzioni e prove di dominio. I path operativi sono relativi alla
root del repository; questo collegamento è relativo alla directory della skill.

Questo file è il protocollo comune, mantenuto in `method` e distribuito come
fork versionato. `domain.md` resta locale, anche in `method`. Nel recepire
aggiornamenti con `/method`, confronta separatamente protocollo, profilo e
strumenti; conserva gli adattamenti motivati. Il wrapper Codex rinvia a questa
skill senza duplicarne le istruzioni.

La richiesta di diagnosi non autorizza correzioni. Se il custode ha già chiesto
anche l'intervento, applicalo dopo aver formulato il giudizio, entro quello
scope; non richiedere di nuovo un consenso già disponibile. La review di una
procedura non ne autorizza l'esecuzione sul Mondo.

## Audit

Esegui i comandi dichiarati nel profilo. Registra checkout e modifiche locali
pertinenti; controlla gli esiti effettivi, non soltanto gli exit code. Se un
comando o una fonte non è disponibile, dichiara il controllo non eseguito e
continua quelli indipendenti.

Il profilo quantitativo identifica il corpus, le esclusioni, le dimensioni e
gli stati di maturità. L'audit locale aggiunge catalogo, rete, riferimenti e
facet. Per ogni misura riporta oggetto, numeratore/denominatore quando
applicabile, esclusioni e limite: `coverage` del codice non è copertura delle
fonti né della conoscenza. Non confrontare percentuali con perimetri diversi.

Classifica errori, warning e falsi positivi con il loro motivo. Una menzione
testuale non dimostra documentazione sufficiente; un path esistente non prova
che il suo contratto sia descritto correttamente. Cluster, backlink, dimensioni,
maturità dichiarata e termini frequenti orientano l'attenzione, senza soglie di
qualità o obblighi di creare nodi.

Il profilo dichiara anche il guardiano delle skill, `skill_tools.py audit`,
lanciato dal checkout del canone (`method/../o3/skill_tools.py` in un
adottante): dimensioni e crescita, rimandi, comandi scritti contro i permessi
di sessione e giro, divieti scritti con o senza deny, chiamate fra skill,
esempi di trailer contro il gate, divergenza dalle copie canoniche. Sono candidati: la classificazione resta un
giudizio (`kb/agent-as-user.md`, `kb/skill-composition.md`).

Concludi l'audit con corpus, controlli eseguiti/non eseguiti, anomalie e limiti.
Non avviare implicitamente la review. I controlli leggeri degli ingressi
eventualmente richiesti dal profilo restano distinti dalla lettura integrale.

## Review

### Riferimento e copertura

Leggi integralmente, nella KB canonica risolta dal profilo:

- `cognitive-fidelity.md`;
- `kb-content-typology.md`;
- `node.md`;
- `source-of-truth.md`.

Leggi README, CLAUDE, `goal.md`, `world.md`, catalogo e tutti i nodi locali.
L'inventario viene dal filesystem, non dal solo catalogo: includi i nodi non
indicizzati. Non campionare una review dichiarata integrale. Puoi leggere per
gruppi, ma torna sulle relazioni tra gruppi prima del giudizio finale.

Usa il manifest del profilo per un ledger temporaneo, una voce per nodo:

- path e impronta del contenuto letto; lettura completa oppure ancora parziale;
- funzione dominante e regione di contenuto, ammettendo contenuti misti;
- affermazioni rilevanti: tipo, fonte, riscontro e limite della verifica;
- disposizione proposta e motivazione.

La copertura si dimostra riconciliando ledger e manifest, non compilando
automaticamente giudizi sui file. Rileggi le parti cambiate se il corpus muta
durante il lavoro. Una review interrotta è parziale: esplicita file non letti e
verifiche mancanti, senza estendere il verdetto all'intero corpus.

Leggere tutti i nodi non significa verificare tutte le loro affermazioni.
Seleziona quelle da riscontrare per costo dell'errore, incertezza, volatilità
e importanza fondativa; rendi visibile la selezione. Se una fonte decisiva manca,
sospendi quel giudizio, continuando le verifiche indipendenti.

### Affermazioni e fonti

Per le affermazioni selezionate distingui:

- fatto osservato: oggetto, periodo, condizioni e fonte dell'osservazione;
- interpretazione o ipotesi: evidenza, passaggio inferenziale e condizioni che
  potrebbero smentirla;
- decisione o norma locale: autorità che la stabilisce e campo di applicazione;
- attribuzione a un autore o tradizione: testo e contesto che la sostengono,
  distinti dall'uso interpretativo che ne fa il progetto.

Registra riscontri come `confermato`, `contraddetto` o `non verificato`,
con fonte e limite; il mancato riscontro non è una confutazione. Non trattare
una sintesi, la sua vista e un testo che la ripete come prove indipendenti.
Per le fonti esterne distingui disponibilità, effettiva consultazione e
pertinenza; una citazione bibliografica non equivale a una verifica.

Prima di segnalare una contraddizione confronta oggetto, tempo, condizioni,
significato dei termini e autorità delle affermazioni. Conserva osservazioni
discordanti quando non hai evidenza per risolverle. Distingui configurazione,
assetto di riferimento e stato realmente osservato.

Cerca anche riferimenti in backtick o testo semplice: il link checker non
garantisce di coprirli. Un fatto volatile ha una sede documentale di riferimento,
ma può avere più osservazioni primarie: non cancellarle per imporre unicità.

### Funzione, accessibilità e lacune

Assegna una funzione dominante: modello del dominio o della macchina, norma,
reference, router, orientamento o conoscenza procedurale. La funzione non è la
regione di contenuto. Valuta il baricentro sul dominio osservato, non su una
distribuzione ideale uguale per tutti.

Verifica la distinzione tra README, CLAUDE, register, catalogo e nodi.
Controlla anche che le descrizioni del catalogo concordino col contenuto.
Una KB giovane può essere piccola; una rete di concetti brevi può essere ben
atomizzata; un hub molto collegato può essere un buon ingresso.

Scegli domande concrete dai goal, dagli attriti osservati e dal profilo locale.
Per ciascuna percorri ingresso → nodo → fonte/limite → decisione informata.
Riporta il percorso effettivo e l'eventuale punto in cui manca conoscenza,
orientamento o evidenza. La lettura di un runbook non richiede eseguirlo.

Cerca anche conoscenza necessaria ma assente. Prima di proporre un nodo nuovo,
verifica se basta arricchire un nodo, collegare una fonte o migliorare il router.
Non convertire una domanda senza risposta in una serie di nodi per copertura
tematica; stato, segnali e lavoro futuro possono appartenere ad altre collezioni.

### Storia, confini e potatura

Separa cronaca redazionale superata e storia del dominio ancora necessaria:
Git conserva la prima; date cliniche, titoli, riconciliazioni e catene causali
possono costituire conoscenza corrente. La ricostruibilità in Git non basta
a giustificare la perdita di una spiegazione usata nelle decisioni.

Conserva invarianti, lezioni, assunzioni e alternative scartate che impediscono
errori ricorrenti. Distingui conoscenza procedurale riusabile da prescrizioni
predisposte per un atto specifico; applica il confine locale dichiarato.
Verdetti correnti stanno in i3, lavoro futuro in o1/o2.

Valuta responsabilità e uso, non la sola somiglianza lessicale:

- fondi nodi privi di funzione autonoma;
- dividi responsabilità consultate separatamente o con ritmi diversi;
- rendi router i panoramici che duplicano reference e troubleshooting;
- rifinisci titolo, apertura, lessico ed esempi dove ostacolano l'accesso.

Classifica i nodi `mantieni`, `rifinisci`, `fondi`, `dividi`, `elimina`;
aggiungi `giudizio sospeso` quando mancano elementi decisivi. Tieni separati
disposizione editoriale e riscontri fattuali: `mantieni` non certifica tutti i
fatti. Elenca a parte le lacune, con domanda d'uso e rimedio minimo.

Un contenuto giustifica il proprio peso se informa decisioni, distingue casi,
comprime regole, conserva evidenza o sostiene un uso reale. Non fissare quote
di riduzione né usare le righe eliminate come misura della qualità.

Prima di proporre fusione o eliminazione, verifica la destinazione di ogni
contenuto ancora utile e i percorsi che vi conducono. Se occorre una nuova
superficie, proponine la creazione prima della rimozione. Nessuna potatura finché
la destinazione non esiste ed è fedele. Distingui riferimenti vivi da menzioni
storiche in i2, i3 o Git: queste ultime non si riscrivono automaticamente.

### Skill

Leggi le skill locali contro `skill.md`, `skill-composition.md` e
`agent-as-user.md`, partendo dall'uscita del guardiano. Per ciascuna: compie
un atto con un contratto di esito dichiarato? È base, composta o ramo, e
rispetta le due regole di composizione? Le sezioni che non sono procedura
duplicano un nodo o appartengono a `kb/`, a un register o a uno script? I
rimandi sono condizionali, legati al punto in cui servono? Ogni divieto
scritto ha un vincolo vero dietro?

## Esito e intervento

La review restituisce:

- corpus e copertura della lettura, fonti consultate e limiti;
- verdetti distinti su struttura, fatti verificati e utilità semantica;
- rilievi prioritizzati per conseguenze, con file/riga, evidenza, inferenza
  e correzione proposta;
- ledger completo, anche in appendice temporanea, inclusi nodi mantenuti e
  giudizi sospesi; nessuna certificazione per omissione;
- prove di navigazione, lacune e nodi ben riusciti da preservare;
- ordine d'intervento, destinazioni e rischi di perdita informativa.

Se è richiesta soltanto diagnosi, presenta le correzioni per la decisione del
custode. Se l'intervento è già autorizzato, correggi prima contraddizioni e
riferimenti morti, poi lacune e sovrapposizioni; aggiorna il catalogo a confini
stabilizzati. Non cambiare il goal per rendere coerente la KB.

Non duplicare documentazione per soddisfare un controllo mal delimitato:
correggi il controllo quando la fonte appropriata esiste già. Dopo fusioni o
eliminazioni classifica i riferimenti residui; formatta, rigenera le viste
pertinenti e ripeti audit e check locali. Confronta conteggi con lo stesso
perimetro, rendendo esplicite eventuali variazioni.

L'output deterministico resta rigenerabile; il ledger è materiale di lavoro
temporaneo, non un nuovo registro della KB. Non archiviare automaticamente il
report completo. Durante l'intervento autorizzato conserva invece ciò che
cambia: conoscenza durevole nei nodi, sintesi interpretative necessarie in i2,
giudizio corrente nel filo i3, lavoro futuro in o1/o2. Una conclusione semantica
non è riproducibile come un conteggio; preservane il razionale nella superficie
pertinente. Il gate `/commit` verifica questo filing back quando richiesto.
