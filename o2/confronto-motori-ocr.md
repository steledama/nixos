---
sintesi: "MiniCPM diretto scelto al posto di GLM su game e Paddle small CPU come riserva su deck; completare l'integrazione e l'attivazione."
ciclo: runtime
decidere: "Autorizzare rebuild e avvio di llama-cpp su game per attivare il preset MiniCPM già collaudato?"
---

# Integrare MiniCPM OCR e Paddle CPU

## Decisione e risultato atteso

Il custode ha deciso il 2026-11-14, tramite la sessione economia, di
sostituire GLM-OCR con MiniCPM diretto su game e predisporre Paddle small
CPU su deck come riserva. Ha affidato l'analisi qualitativa a economia e
ha escluso il secondo confronto tabellare: una sua lettura alla cieca non
è condizione di questo cambio. L'SDK layout resta specialistico.

La scelta del motore è concordata; sudo, rebuild e avvio del servizio di
sistema restano soggetti alla loro autorizzazione locale. Il campione
pilota non prova affidabilità generale su tabelle o altri documenti.

## Confine con economia

La sessione economia custodisce il PDF reale, immagini, output integrali,
misure per richiesta e valutazione dei campi. Il campione iniziale ha due
pagine scansionate, italiano e scrittura manuale; non contiene vere tabelle.
Dati e risultati personali restano locali nel suo percorso
`cache/confronto-ocr-romana/`, fuori dal repository pubblico nixos.

Nixos prepara gli ambienti e i backend e conserva soltanto requisiti,
versioni, misure aggregate e limiti utili all'infrastruttura. Tutta
l'inferenza è locale; nessuna API OCR esterna.

## Protocollo

- Stesso PDF e PNG comuni a 200 dpi, con hash e preprocessing registrati.
- Baseline GLM-OCR con binario e preset attuali; MiniCPM Q8 con proiettore
  e DSpark ufficiali; PaddleOCR con modelli e numero di thread espliciti.
- Distinguere download/installazione, avvio e caricamento del modello,
  preparazione PDF, inferenza e salvataggio. Prima richiesta con modello
  scarico, poi tre passate calde; cache disco non svuotata.
- Per il confronto senza riuso di contenuto, `cache_prompt=false` su
  llama.cpp. Le misure con riuso del prompt restano un caso separato.
- MiniCPM si prova sulla pagina e con il layout dell'SDK: la pipeline
  completa comporta costi aggiuntivi da includere nei tempi.
- Valutare omissioni, numeri e date, testo manuale, ordine di lettura e
  aggiunte non presenti. L'OCR corrente non è una verità di riferimento.
  La valutazione finale del custode avviene su risultati anonimizzati.

## Risultati e integrazione

Misure aggregate, versioni e limiti sono in
[confronto-ocr-locale](../i2/confronto-ocr-locale.md). GLM, MiniCPM diretto,
Paddle CPU e MiniCPM con layout sono stati misurati. La decisione non
richiede altri benchmark.

- Configurazione GPU: nel modulo `llama-cpp.nix`, alias `minicpm-ocr`,
  tre pesi fissati nello store, caricamento su richiesta e DSpark. Catalogo
  e richiesta sintetica passati con il preset generato da Nix in un router
  temporaneo; anche il client economia aggiornato ha passato il collaudo.
- Riserva CPU: `ocr-cpu` su deck, con modelli nello store; build, test senza rete e switch Home Manager riusciti.
- Contratto economia: `http://game:11434/v1/chat/completions`, modello
  `minicpm-ocr`, prompt `Text Recognition:`, temperatura zero,
  `cache_prompt=false`. La CLI CPU accetta immagini e JSON opzionale;
  rendering PDF e salvataggio dei risultati restano a economia.
- Attivazione GPU: predisporre la revisione per game e il comando minimo
  per rebuild e avvio manuale del servizio, poi verificare la generazione
  attiva e il nuovo catalogo. Nessuna variazione di rete o del modello chat.

## Chiusura

Il task si chiude con riserva CPU installata e provata su deck e servizio
MiniCPM attivato e verificato su game. Registrare ciò che è davvero attivo,
coordinando il runbook di economia. La chiusura tecnica non certifica il
contenuto del documento contrattuale e non chiude il suo task di dominio.

## Connessioni

- [game-local-llm](../kb/game-local-llm.md)
- [confronto-ocr-locale](../i2/confronto-ocr-locale.md)
- [plan](../o1/plan.md)
