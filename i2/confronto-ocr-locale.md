---
sintesi: "Prova pilota sullo stesso documento italiano di due pagine: MiniCPM-OCR Q8 con DSpark migliora tempo e copertura dei campi rispetto a GLM-OCR; PaddleOCR small funziona sulla CPU N150, con tempi maggiori."
ciclo: runtime
---

# OCR locale su GPU e CPU

## Campione e provenienza

Misure della sessione con il custode del 2026-11-14. Economia custodisce il
PDF reale di due pagine scansionate in italiano, con testo stampato e
manoscritto, le immagini comuni a 200 dpi e i loro hash, gli output e i
runner. Il documento non contiene vere tabelle. Nel repository pubblico
nixos restano soltanto misure aggregate e informazioni infrastrutturali.

Tempi misurati dalle richieste del client in economia, su quattro passate:
prima richiesta e tre ripetizioni. La verifica qualitativa è dell'agente di
economia contro le immagini, con 18 campi trascritti manualmente: cinque
monetari, sei date contrattuali e sette attributi catastali. Non è una
valutazione umana alla cieca né una misura CER/WER dell'intero testo.

## Riconoscimento dalle stesse immagini

Modello caricato, nessun riuso del prompt (`cache_prompt=false` su
llama.cpp). Tempi in secondi; totale è la mediana dei tempi delle coppie di
pagine. Rendering del PDF, installazione e avvio sono esclusi.

- **GLM-OCR Q8 su game:** pagina 1 3,937 s; pagina 2 2,502 s;
  documento 6,461 s. Campi critici 17/18: una data omessa, nessun campo
  controllato errato. Omette anche intestazioni e firme.
- **MiniCPM-OCR 1.0 Q8 con DSpark su game, pagina intera:** pagina 1
  2,706 s; pagina 2 1,803 s; documento 4,510 s. Campi 18/18;
  recupera intestazioni e la data omessa da GLM. Restano errori testuali e
  letture errate o omissioni sulle firme.
- **PP-OCRv6 small su deck, sola CPU:** pagina 1 30,131 s; pagina 2
  17,055 s; documento 47,290 s. Campi 18/18; errori di accenti e
  spaziatura e letture spurie dei manoscritti. Output identici nelle quattro
  passate.

La riduzione di tempo di MiniCPM diretto rispetto a GLM sul documento è
circa il 30%, derivata dalle due mediane misurate. L'uguaglianza sui campi
non implica uguaglianza di qualità dell'intero testo.

Il caso GLM con prompt riusato, misurato separatamente, impiega 3,944 s
per documento: non è il confronto adatto a nuove pagine.

## Avvio, dipendenze e limiti

- `game`: RTX 4070 da 12 GiB, driver 595.112.07; stesso llama.cpp 0.8.0,
  build 11960, commit 8642541 per entrambi i modelli. GLM usa il preset
  installato. MiniCPM usa Q8, proiettore F16 4x e DSpark Q8, contesto 8192,
  uno slot, reasoning disattivato; il journal conferma DSpark attivo.
- Le revisioni ufficiali MiniCPM sono
  `0133ad8db635210441a55dcf421e25bfb9915142` (modello/proiettore) e
  `cab493a5a26516a1c4c6e07c73b4470ff854a898` (DSpark). Gli SHA-256
  dei file sono nel manifesto privato conservato col confronto.
- MiniCPM carica prima di dichiararsi pronto (circa 1,31 s nel journal),
  GLM nel router carica su richiesta. La prima passata dalle PNG è 8,349 s
  per GLM e 4,737 s per MiniCPM: non comprende la stessa quota di avvio.
  Non confrontarla come tempo totale a freddo.
- `deck`: Intel N150, quattro core; Python 3.12.15, PaddleOCR 3.7.0,
  PaddleX 3.7.2, PaddlePaddle 3.3.1. Quattro thread, modelli small,
  orientamento e raddrizzamento disattivati. Import 4,535 s e caricamento
  4,667 s, prima passata 48,293 s, separati. Cache disco non svuotata.
- oneDNN ha fallito con `ConvertPirAttribute2RuntimeAttribute`;
  disattivandolo la prova CPU funziona. Questi tempi non misurano il
  potenziale di una pipeline OpenVINO o di altre ottimizzazioni non provate.
- Ambienti Python isolati e servizi utente temporanei: nessun nuovo
  servizio permanente, rebuild o sostituzione del backend stabile.

## Pipeline con layout

Anche l'SDK MiniCPM 1.0.5 è stato provato sullo stesso input: rilevamento
PP-DocLayoutV3 su CPU di deck e riconoscimento MiniCPM su GPU di game.
PaddleX 3.4.2, PaddlePaddle 3.2.1 e OpenCV 4.10.0.84, in un ambiente
separato. Modello di layout dal mirror ufficiale PaddlePaddle su Hugging
Face, revisione `241f8bdfc77a7c7bee915a5057aaee58c235a8d3`.

Un worker, contesto 8192, nessun raddrizzamento, tutti i tipi di blocco
conservati nel Markdown e OCR dei blocchi immagine. Le quattro invocazioni
CLI ricaricano import e layout; la GPU è già pronta. Prima invocazione
20,844 s, successive 15,115 / 17,844 / 15,140 s: mediana 15,140 s. Queste
sono durate di processo della pipeline, non tempi puri di riconoscimento
comparabili alla tabella precedente. La prima prova ha completato 25 blocchi
senza errori. Anche la pipeline con layout recupera 18/18 campi
critici, verificati nelle rispettive associazioni nel contesto.

Il layout recupera altri segni manoscritti ma ne trascrive diversi in modo
errato: sul campione non emerge un miglioramento qualitativo uniforme che
compensi la pipeline aggiuntiva. Non è una conclusione sulle tabelle o su
altri tipi di documento, assenti dalla prova.

## Preparazione del PDF e costo pratico

Il rendering comune a 200 dpi richiede una mediana misurata di 1,173 s.
Questo tempo è separato dai riconoscimenti. Le somme fra rendering e tempi
OCR sono stime derivate, non un'unica esecuzione end-to-end cronometrata.
Anche download, installazione e avvio dei backend restano separati.

La via diretta MiniCPM riusa il binario già installato su game. L'SDK
aggiunge un ambiente Python e il modello di layout. Anche la via Paddle CPU
richiede un ambiente Python proprio: il tempo di inferenza da solo non ne
misura il costo di manutenzione. Runner, lock delle versioni installate e
manifesto delle prove sono conservati da economia insieme ai risultati.

Dopo le prove le unità utente temporanee sono state fermate, la GPU è stata
liberata e il servizio di sistema è rimasto inattivo come prima della prova.
I pesi e gli ambienti di prova restano in `/tmp/nixos-ocr-bench` sui due host
per l'eventuale integrazione; non sono un'installazione permanente.

## Lettura e decisione

Sul campione MiniCPM diretto è un candidato favorevole: più rapido e con
una omissione critica in meno. Paddle small è una via CPU concretamente
misurata per documenti brevi quando game è spento. Sono esiti di questa
prova pilota, non previsioni di qualità su altri documenti o tabelle.

Il custode ha affidato l’analisi qualitativa alla sessione economia e ha
deciso il 2026-11-14 MiniCPM diretto al posto di GLM e Paddle small come
riserva CPU. Ha escluso altri confronti tabellari e non richiede una propria
lettura alla cieca per questo cambio. L’analisi delegata non è un giudizio
umano indipendente alla cieca. L’attivazione è distinta dalla decisione e
si segue nel task di integrazione. Il miglioramento
sull'italiano è osservato nel campione: la documentazione upstream presenta
MiniCPM soprattutto per cinese e inglese, e non sostituisce questa prova.

Le fonti upstream sono il repository ufficiale
[MiniCPM-OCR](https://github.com/OpenBMB/MiniCPM-OCR), la sua
[guida llama.cpp](https://github.com/OpenBMB/MiniCPM-OCR/blob/main/docs/llamacpp_deploy.md)
e [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR); versioni e
prestazioni dichiarate dagli autori restano distinte dalle misure locali.

## Connessioni

- [game-local-llm](../kb/game-local-llm.md)
- [confronto-motori-ocr](../o2/confronto-motori-ocr.md)
- [goal](../goal.md)
