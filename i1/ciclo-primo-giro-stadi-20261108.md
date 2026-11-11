---
ciclo: runtime
---

# Primo giro con gli stadi verificati: lettura fatta, giudizio sottile

Caso della delega (`eval perceive`, passo 3). Stato: **acquisita da method**
il 2026-11-08 (`083a8e7`,
`i1/giri-lettura-fatta-giudizio-sottile-2026-11-08.md`); canone deciso a
`21d4713`, da recepire con `/method`.

## Situazione

Il 2026-11-08, in sessione su `deck`, il custode ha chiesto un'analisi del
giro autonomo delle 04:30 (commit `295819e`, tentativo
`93476b91b9c7448bbc77ad4a3833179e`). È il primo giro dopo gli allineamenti
del 2026-11-07 (`4c4a27c`, `537c45c`, `aa4af49`), nati dal caso
`i1/ciclo-stadi-saltati-20261107.md`. Sono stati letti trascrizione,
`tentativi.jsonl`, commit, registro e l'output di ogni chiamata citata.

## Confine

Il canone ora chiede un minimo di letture per stadio e `commit_gate.py stadi`
ne controlla la traccia: skill invocata e presenza del path nella
trascrizione. Né il minimo né il gate dicono se il giudizio formato su quelle
letture regge. Due punti del canone si scontrano con la pratica:
`exec/plan.md` prescrive una pipe che `cycle` vieta nel giro, e `eval` dice
che `/manutenzione` non si esegue da `perceive` mentre `cycle` la mette
dentro `perceive` e `perform`.

## Comportamento

**Autonomia riuscita, con riscontro.**

- `cycle`, `eval`, `exec` e `commit` invocate col tool Skill, zero dinieghi su
  queste. Ogni minimo ha la sua traccia. `commit_gate.py stadi`: sei lacune
  sul giro del 2026-11-07, `ok` su questo.
- `Attenzione:` non più «nessuna», identica fra commit e resoconto.
- `perform` ha tolto da `o3/prescriptions.md` i residui dei rami usciti il
  2026-11-04.
- Costo 2,32 USD, 100 turni, 9,3 minuti. Contro i giri con bump simili (25
  ottobre e 1 novembre, circa 1,95 USD; derivato, quei giri curavano anche
  `norvegia`) gli stadi costano circa 0,40 USD in più. `/manutenzione` ha
  preso 6'49" su 9'18", il resto di `eval` 21 secondi, `exec` 58 secondi.

**Lacune.**

- **Finestre a numero fisso.** Fra i due giri c'erano 35 commit del custode.
  `git log --oneline -15` di `compare` si ferma alle 17:10 del 7 novembre e
  non vede la migrazione di `game` né il lavoro su Drive e rclone, che
  toccano l'obiettivo 2. Il `Prossimo:` letto con `-20` esce vuoto: il giro
  ha tolto la pipe prescritta e aggiunto il limite, poi ha scritto «letto
  male» senza trovare la causa e senza proposta.
- **Visione d'insieme non eseguita come prescritta.** Il comando chiede i
  corpi dei commit (`%b`), il giro ha letto gli oggetti (`%s`); la serie delle
  due settimane non è stata letta. Il resoconto scrive comunque «nessun
  rilievo». Gli è sfuggito lo stesso comando negato il 6 e l'8 novembre.
- **Rischio assegnato senza fonte.** Kernel «changelog non consultato» contro
  `valutazione.md`; Chromium una sola ricerca, senza `WebFetch` concesso.
  `medio` ha deciso la mancata promozione.
- **Fatti non riletti nel giro, scritti al presente.** #9289 «ancora aperta»
  dal registro del 27 ottobre (vera, verificata poi in sessione); «nessuna
  ricorrenza» dove il canale è la segnalazione del custode; «circa 2,2 USD»
  senza alcuna fonte, reale 2,32; «quattro comandi» erano sei.
- **Ordine.** Bump e switch (04:32, 04:36) precedono la lettura di `goal.md`
  (04:37): il verdetto non può più influire sugli atti del giro.
- **`compare=materia` per una nota su sé stesso.** L'unica modifica è la
  riga sul giro in `i3/allineamento-metodo.md`. Nessuna traccia della
  copertura degli obiettivi 2 e 3.
- **Resoconto.** Manca l'autovalutazione degli stadi, gli esiti la
  sostituiscono; manca la voce delle decisioni entro la delega.

## Riscontro

Nessun danno: home e sistema di `deck` allineati a `295819e`, nessuna unità
fallita, nessun file vietato toccato, nessun criterio di sospensione. Il giro
`salute` delle 09:00 ha usato `gog` dopo il bump. La migrazione di `game` non
ha lasciato residui nei file che citano l'utente vecchio.

Correzione locale del 2026-11-08, in sessione col custode:

- `o3/ciclo/prompt.md`: comandi singoli dalla prima chiamata, finestre
  dall'ultimo giro, letture esplicite della visione d'insieme, fatti con
  data e canale, autovalutazione stadio per stadio;
- `/manutenzione`, `valutazione.md`: fonte aperta per browser e kernel,
  `rischio: non valutato` se manca.

## Questione per il metodo

- Le finestre di `compare` (`-15`) e il comando del `Prossimo:` devono
  partire dall'ultimo giro invece che da un numero, nel canone? Il comando
  con pipe va riscritto, perché `cycle` la vieta.
- Il minimo misura la lettura. Serve una traccia del giudizio, per esempio
  ogni filo con la sua risposta a «è ancora vero?» e il segnale usato, o la
  copertura degli obiettivi dichiarata nel resoconto? Il gate può controllare
  almeno che ogni filo e obiettivo sia nominato?
- Il passo 3c è verificabile dal gate (comando coi corpi, serie dei
  tentativi)?
- Gli atti di una procedura di dominio stanno prima o dopo `compare`?
  «La verità prima delle priorità» oggi non vale per gli atti del centro del
  giro: `eval` e `cycle` si contraddicono.
- `materia` su una nota che riguarda solo il giro stesso va distinto, o basta
  leggerlo?
