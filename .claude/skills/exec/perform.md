# perform — l'atto e la sua collezione

In NixOS `o3/` non è solo una collezione di prescrizioni: è l'**output runtime
reale** — configurazione dichiarativa in `o3/home/`, `o3/hosts/`, `o3/modules/`,
dati in `o3/identity/`, patch in `o3/patches/`, diagnostica in `o3/scripts/`,
strumenti di sviluppo in `o3/tools/`. Due piani, secondo autorizzazione:

- **La supervisione della collezione**: `o3/prescriptions.md` tiene solo il
  vivo — una prescrizione consumata (rebuild eseguito, script assorbito, task
  chiuso) si pota insieme alla sua voce (cfr. `method/perform.md`); gli
  strumenti registrati sono ancora eseguibili
  (`o3/tools/check.sh`, `method/../o3/view/build.py --root .`, `kb_tools.py` girano
  davvero); la sezione «Strumenti» riflette ciò che c'è in `o3/tools/` e
  `o3/view/`, non uno stadio superato.
- **L'atto stesso**, sotto la regola locale del repository — la stessa di
  `CLAUDE.md`, che questo stadio non allarga:
  - file in `o3/modules/home/` o `o3/home/` → home-manager-level: l'atto è
    `o3/scripts/con-identita.sh home-manager switch --flake .#user@host`, **si compie** (locale,
    reversibile, già autorizzato);
  - file in `o3/modules/system/` o `o3/hosts/` → system-level: l'atto è
    `o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake .#<host>` e **non si compie qui** — si
    predispone il comando minimo, si dichiara l'host (e l'ordine, se sono
    più d'uno), e ci si ferma al confine dell'autorizzazione;
  - il push del branch corrente segue il commit (`CLAUDE.md` «Push remoto»);
    `push --force`, altri branch e operazioni distruttive restano fuori in
    ogni caso.
- **Nel ciclo autonomo** l'atto è quello ricorrente del runtime, cioè la
  fase atti di `/manutenzione`, dopo `compare` e `plan`, e `remoto` secondo
  `autonomy.md` (`ciclo-autonomo`); i
  passi di un task `o2/` restano alla sessione col custode
  (`method/tasks.md`, «Task e giro»).

Esito: stato della collezione (prescrizioni vive e loro freschezza, strumenti
verificati), atti compiuti o predisposti col comando minimo, o la chiusura in
una riga.

Minimo: `o3/prescriptions.md` e gli atti che `autonomy.md` assegna al giro;
`/manutenzione` non è il giro: la sua diagnosi è un canale di `perceive`, i
suoi atti stanno qui, dopo `compare` e `plan` (`cycle`, «Stadi»).
