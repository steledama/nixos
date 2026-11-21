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
lavoro che il custode lancia in sessione su `deck`, capogruppo del repo;
gli altri host recepiscono con pull e switch. Le questioni importanti si decidono insieme,
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
- **Preparazione remota:** criterio `preparazione-remota`. In sessione col
  custode, per un aggiornamento richiesto di game o neve, da deck l'agente
  può usare SSH per `nix eval` e `nix build` non-sudo sul destinatario,
  tramite il suo `o3/scripts/con-identita.sh`, anche nei controlli degli
  script `system-drift.sh` e `home-drift.sh`. Prima verifica il checkout
  `~/nixos`: branch `main`, tree pulito e commit da preparare già pubblicato;
  può portarlo a quel commit con `git pull --ff-only`, senza merge o rebase.
  Con modifiche locali, divergenza o una build dello stesso aggiornamento
  già in corso, si ferma sul solo host interessato. Eval e build si avviano
  con `systemd-run --user` sul destinatario: sono consentiti avvio del
  servizio di preparazione, lettura di stato e log e pulizia dell'unità
  conclusa, senza sudo. Il processo deve continuare se cade SSH.
  Questa preparazione
  popola lo store del destinatario e non attiva sistema o home; gli switch
  home remoti restano a `remoto`. Non vale sugli host di lavoro. Procedura: `kb/development-workflow.md`.
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

## Nessun ciclo senza custode

A casa non gira alcun ciclo autonomo: su `deck` `method`, `nixos`, `salute`
ed `economia` si lanciano a mano, in sessione (custode, 2026-11-20). Il
confine che un giro senza custode richiederebbe costa più di quanto renda
su una postazione di casa, dove privacy e minimalismo prevalgono
([confine dei cicli](i2/confine-dei-cicli.md)). Nessuna unità né
timer avvia un agente: il meccanismo dell'host è stato tolto e resta in
git.
Riattivare un giro senza custode è un cambio di territorio: si decide col
custode secondo `confine-delega`.

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
dal custode, gli unici a casa. Il
custode può restringere o revocare la delega; il register e Git ne
conservano lo stato e la storia.
