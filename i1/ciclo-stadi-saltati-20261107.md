---
ciclo: runtime
---

# Giri autonomi ridotti a /manutenzione

Caso della delega (`eval perceive`, passo 3). Stato: **acquisita da method**
il 2026-11-07 (`1516fa8`, `i1/giri-stadi-dichiarati-senza-traccia-2026-11-07.md`).

## Situazione

Il 2026-11-07, in sessione su `deck`, il custode ha chiesto un'analisi degli
esiti del ciclo autonomo di nixos. Sono stati letti 21 giri, dal 2026-10-17 al
2026-11-07: `i1/giri/tentativi.jsonl`, le trascrizioni in `i1/giri/giri/` e i
commit con `Impatto-motivo: ciclo-autonomo`.

Tutti i giri dal 2026-10-20 sono riusciti, con commit, push e tree pulito.
Nessuno ha toccato file vietati: i commit su `o3/cicli.nix` e `o3/hosts/`
portano `ciclo-delegato` o `giudizio`, cioè vengono da sessioni col custode.

## Confine

La skill `cycle` prescrive `eval all → exec all → /commit` e dice di seguire
le skill `eval`, `exec` e `commit`. Il prompt del giro mette `/manutenzione`
al centro degli atti. Né la skill né il gate verificano che gli stadi
dichiarati siano stati eseguiti.

## Comportamento

- **Stadi non eseguiti.** Tutti i giri invocano solo la skill `cycle`.
  Fino al 2026-11-04 aprivano almeno i file `SKILL.md` di `eval` ed `exec`.
  L'1 e il 3 novembre li avevano già saltati, e dal 5 novembre non lo fa più
  nessun giro. Nessun giro legge `goal.md`. Gli ultimi quattro non leggono
  nulla di `i2/` né di `i3/`. Il giro del 2026-11-07 (37 turni, 2,5 minuti)
  ha fatto `/manutenzione`, le derive e un ritocco al task in testa.
- **Trailer `Esiti:` inesatto.** Le skill dicono che gli stadi non invocati
  non compaiono. I giri invece scrivono sempre tutti e sei gli stadi:
  `interpret=vuoto` in 20 giri su 21 senza aver eseguito lo stadio,
  `compare=vuoto` senza aver letto i fili, `perceive=materia` in 21 su 21
  senza una cattura in `i1/` oltre al registro e senza il passo 4 (lettura
  della chiusura precedente e dei suoi dinieghi).
- **Autovalutazione cieca.** L'autovalutazione richiesta dal prompt è quella
  della procedura `/manutenzione`, quindi non ha visto la riduzione: dal 5 al
  7 novembre i giri chiudono con `Attenzione: nessuna`.
- **Attenzioni senza memoria.** Dal 20 ottobre al 3 novembre quasi ogni
  giro ripete la stessa attesa sullo standby. Il 31 ottobre un'unità
  Noctalia fallita è segnata «non indagata» e nessun giro successivo la
  riprende. Il 3 novembre un giro dichiara allineati i server fidandosi di
  `system-drift.sh`, che non vedeva il pin `ai`: lo corregge il giro
  seguente.
- **Costo in calo per sottrazione.** Durata e costo scendono da circa
  8 minuti e 1,5 USD a 2,5 minuti e 0,9 USD perché il giro fa meno lavoro.

## Riscontro

`python3 o3/tools/kb_tools.py audit` e `fidelity` di oggi non trovano
drift: nei venti giorni la riduzione non ha prodotto danni visibili nella
KB. Ha però tolto la misura che il trailer `Esiti:` doveva dare, e il
verdetto dei fili contro il Goal non è mai stato rinnovato dai giri.

Correzione locale del 2026-11-07, in sessione col custode, in
`o3/ciclo/prompt.md`:

- un minimo verificabile per stadio;
- `Esiti:` limitato agli stadi eseguiti, con lo stadio saltato in
  `Attenzione:`;
- autovalutazione di copertura oltre a quella di procedura;
- regola delle attenzioni invariate e di quelle non indagate.

## Questione per il metodo

- Il gate `commit_gate.py dopo --giro` accetta qualunque `Esiti:`
  sintatticamente valido. Deve controllare, sulla trascrizione del giro o su
  un'evidenza dichiarata, che ogni stadio nominato sia stato eseguito?
- `cycle` compone `eval` ed `exec` per riferimento: nel modo autonomo deve
  chiedere di invocarle come skill, con un minimo per stadio dichiarato dal
  canone e un adattamento per repo?
- Il valore `vuoto` confonde «eseguito senza materia» con «non eseguito»:
  serve un terzo valore, o basta far valere la regola dell'omissione?
- L'autovalutazione di copertura (gli stadi fatti) va nel canone del giro,
  accanto a quella di procedura?
- Gli altri adottanti (`salute`, `economia`, `method`, `nixos-lavoro`)
  hanno la stessa deriva?
