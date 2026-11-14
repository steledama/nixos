# Autonomia

Il custode conserva scopi, territorio e condizioni della delega. L'agente
conduce il ciclo operativo di `nixos` nel perimetro concesso e ne rende
leggibili gli esiti. Questo register raccoglie i criteri vigenti, tutti
decisi dal custode e da lui modificabili; quando e come ciascuno è nato lo
dice la storia git del file. La forma è quella canonica di
[consent](method/consent.md), il perimetro è locale. Non concede permessi
oltre le regole operative di [`CLAUDE.md`](CLAUDE.md).

## Ciclo delegato dal custode

Criterio `ciclo-delegato`.

Quando il custode avvia `eval`, `exec` o il ciclo congiunto, l'agente compie
gli scope richiesti e applica gli esiti ordinari senza conferme intermedie.
Una richiesta esplicitamente diagnostica o «solo proposte» restringe il
mandato. Nel ciclo congiunto vale l'ordine `eval → exec → commit`;
l'invocazione di un solo arco non estende lo scope all'altro.

La delega comprende catture pertinenti, sintesi e correzioni delle letture,
verdetti sui goal vigenti, puntatori ai segnali di `goal.md`, priorità,
dipendenze, specifiche dei task, igiene delle collezioni e nodi `kb/`
toccati dagli esiti, con i controlli locali. Un arco chiude col proprio
esito e la proposta di commit; commit e push del branch corrente, nei limiti
di `CLAUDE.md`, li compie `/commit` quando li chiede il custode o la
composta. Una voce nel plan non autorizza da sola un atto sul Mondo.

L'agente verifica le fonti, esplicita provenienza e incertezza e conserva il
presidio delle ipotesi. Una tesi nuova si registra come ipotesi; non diventa
un fatto per rendere eseguibile una decisione.

Impatto minimo **medio** per le decisioni autonome del ciclo: il commit cita
`ciclo-delegato` e i fatti che lo rendono applicabile. Il giudizio può
alzarlo. Il resoconto finale espone decisioni, motivi, verifiche, incertezze
e questioni lasciate al custode. La presenza del custode in chat non
trasforma una decisione dell'agente in una decisione concordata.

Criterio `momento-del-commit`. Nella sessione interattiva il momento del
commit si concorda: le decisioni in discussione restano aperte ad
aggiustamenti e ripensamenti. L'agente propone il commit quando un punto si
è fermato; lo fa di propria iniziativa, dichiarandolo, solo se un lettore
fuori dalla sessione ne ha bisogno, come un'altra sessione o un host che
recepisce. Il ciclo chiesto esplicitamente fino al commit lo include. Il
push segue ogni commit senza conferma.

`/manutenzione` committa e pusha da sola il proprio esito, senza concordare
il momento del commit. Non è un'eccezione al ciclo ma il suo centro: è il
lavoro ricorrente di `nixos` che l'agente gestisce in autonomia, ed è il
nucleo del ciclo autonomo di `deck`, capogruppo del repo; gli altri host
recepiscono con pull e switch. Le questioni importanti si decidono insieme,
secondo `confine-delega`.

## Perimetro NixOS sul Mondo

La delega del ciclo non estende i permessi su host, sudo e rebuild.

- **Atti dentro il ciclo:** solo quelli che `CLAUDE.md` già consente senza
  chiedere — `home-manager switch` sull'host locale per modifiche
  home-level, `systemctl --user`, operazioni git locali e push del branch
  corrente su `origin`.
- **Osservazione degli altri host:** `eval perceive` può leggere via `ssh`
  in sola lettura, senza `sudo`, lo stato dei tre host di casa
  (`journalctl`, `systemctl status`, versioni e generazioni attive), e
  `remoto stato` ne dà il quadro fisso. Nessun comando che modifica stato,
  servizi o file remoti, salvo il criterio che segue.
- **Atti remoti:** criterio `atti-remoti`. Da `deck`, con lo strumento
  `remoto` e mai con `ssh` libero, l'agente manda a `game` o `neve` l'albero
  in staging di `deck`, quello del commit che sta per fare, e ci fa
  `home-manager switch`; dopo il push porta `~/nixos` dell'host al commit
  (`remoto allinea`). Così un solo commit certifica in `applicato_su` gli
  host davvero allineati. L'host non fa `pull` per eseguire: lo switch parte
  dall'albero inviato, il checkout si limita a seguire il commit. `remoto`
  rifiuta gli host di lavoro.
- **Fuori dalla delega:** ogni comando con `sudo`, `nixos-rebuild`, reboot,
  `systemctl` di sistema, ogni altro atto su host diversi da quello locale,
  gli host di lavoro, l'esposizione delle viste e i segreti. L'agente
  predispone il comando minimo, dichiara l'host e si ferma sul punto riservato.
  Quando sudo richiede la password, il custode esegue il comando nel proprio
  terminale interattivo sull'host destinatario; l'agente verifica poi l'esito
  in sola lettura, senza chiedere né gestire la password.
- **Checkout servito:** su `deck` commit, pull e push del ciclo spostano
  `HEAD` e ripubblicano le viste di `nixos` in LAN; la delega vale anche lì
  (canone in [consent](method/consent.md)) e il resoconto dichiara le viste
  ripubblicate. Nessun host esegue file da `~/nixos`: se un ciclo automatico
  iniziasse a fare `pull` ed eseguire dal checkout, il push tornerebbe su
  richiesta finché il custode non sceglie (`CLAUDE.md`, «Push remoto»).
- **Skill con gate propri:** `/manutenzione` segue le regole della propria
  skill; `/method` conserva il gate di conferma del recepimento.

## Ciclo autonomo senza custode

Criterio `ciclo-autonomo`, gradino 1: il timer lancia un giro ogni giorno
alle 04:30, così il resoconto è pronto al risveglio. Un avvio a mano
dell'unità resta coperto da questo criterio.

Il ciclo autonomo è il ciclo congiunto senza custode, la skill `/cycle
autonomo`: lo avvia su `deck` l'unità `ciclo-nixos` del modulo `cicli`, con
`o3/ciclo/prompt.md` e i permessi di `o3/ciclo/permessi.json`. Tetto per
giro: i default del lanciatore, 45 minuti e 5 USD, che il profilo
`o3/ciclo/lanciatore.toml` non cambia. Nessuno risponde durante il giro: una scelta che in sessione si chiederebbe diventa proposta nel task
`o2/` pertinente, il resto va nel resoconto.

Dei task il giro tiene viva la pianificazione, non l'esecuzione
(`method/tasks.md`, «Task e giro»): una notizia nuova, passata per lettura
e verdetto, ne corregge informazioni e specifica, ne muove priorità e
dipendenze, chiude attese, crea o cancella task. I passi del task restano
alla sessione col custode, salvo gli atti ricorrenti che questo criterio
assegna al giro.

Il giro resta fuori da `momento-del-commit`: un commit per giro, con
`Esiti`, `Autonomia: agente`, impatto almeno **medio** e `Impatto-motivo:`
col criterio e il gradino dichiarati dal prompt.

`/manutenzione` è il centro del giro. I rami `ia` e `home-manager` eseguono
da soli bump e `home-manager switch` su `deck`; `casa` e `world` restano
diagnosi. Il giro non agisce su altri host: `game` e `neve` alle 04:30 sono
spenti, e li allinea il custode lanciando `/manutenzione` da loro quando li
accende. Per lo switch l'unità rende scrivibile la home (`homeWritable` in
`o3/cicli.nix`): il recinto del filesystem cade e i permessi dell'harness
sono l'unico confine, scelta consapevole del custode.

Il giro non tocca, nemmeno a commit:

- `o3/modules/system/`, `o3/hosts/`, `o3/identity/`;
- il registro e il modulo dei cicli autonomi: `o3/cicli.nix`,
  `o3/modules/home/cicli.nix`, `o3/modules/home/ciclo/`;
- `.claude/` e `o3/ciclo/` (prompt e permessi del giro, anche in sola
  lettura nell'unità);
- `autonomy.md`, `CLAUDE.md`, `goal.md`;
- lo strumento `remoto`: `o3/modules/home/remoto.nix` e `remoto/`.

Non usa `sudo`, `nixos-rebuild`, reboot, `systemctl` di sistema né `ssh`:
gli altri host li raggiunge solo `remoto`. Il divieto sta nei deny del solo
`o3/ciclo/permessi.json`; nelle sessioni col custode restano le regole di
sopra. Il deny su `remoto` ferma la modifica distratta, non un aggiramento
deliberato (un altro modulo home che installi un comando omonimo): quello
resterebbe nel commit e nello stream del giro, e farebbe scattare la
sospensione.

Sospensione: si torna al manuale dopo un rosso per atto fuori delega, per
uno switch che lascia `deck` o un altro host in uno stato da correggere a
mano o per una ricostruzione sbagliata che altera una decisione. Lo stop per
sessione aperta, il push rifiutato e il lock occupato sono il sistema che
funziona.

## Decisioni riservate e arresto parziale

Criterio `confine-delega`: restano in proposta cambi di scopi, territorio o
criteri di autonomia, atti oltre le autorizzazioni vigenti e decisioni con
incertezza decisiva non risolvibile dalle fonti disponibili. L'agente chiede
la decisione sul punto e prosegue il lavoro indipendente. Impatto alto per
una proposta che cambia i confini costitutivi.

Una proposta persistente vive nel task `o2/` pertinente, indicizzato e
collegato al plan: il campo `decidere:` del frontmatter ne dice la questione
in una frase, il corpo alternative, motivo e decisione richiesta. La home la
elenca finché il campo c'è. Il resoconto la collega; il commit della
proposta non applica l'atto. Quando il custode decide, accettata o respinta,
il campo `decidere:` si toglie e il corpo registra la decisione con la data.

## Casi che delimitano il criterio

- Un riscontro verificato smentisce un filo: correggere filo, letture
  dipendenti e priorità, verificare e committare; `ciclo-delegato`, medio.
- Un dato ambiguo non permette di chiudere un'ipotesi: registrare il limite
  e chiedere sul punto, continuando il resto del ciclo.
- Un esito richiede di cambiare Goal o territorio: predisporre la proposta,
  `confine-delega`, alto; il custode decide.
- Un task chiede un rebuild di sistema: predisporre comando e runbook,
  fermarsi. La delega del ciclo non sostituisce l'autorizzazione esplicita.

## Errori e supervisione

La delega si regge sulla tracciabilità, non sull'assenza di errori. L'agente
dichiara nel resoconto l'errore che scopre e lo corregge con un atto che
lascia traccia, senza riscrivere la storia pubblicata.

Il primo controllo è il resoconto del ciclo con diff e commit consultabili.
I casi in cui il criterio non bastava, le conferme rivelatesi inutili e le
autonomie riuscite con riscontro si raccolgono in `i1/` durante `eval
perceive` e risalgono a `method` come segnale
(`method/method-development.md`). `ciclo-delegato` riguarda i cicli avviati
dal custode, `ciclo-autonomo` il giro senza custode nei limiti sopra. Il
custode può restringere o revocare la delega; il register e Git ne
conservano lo stato e la storia.
