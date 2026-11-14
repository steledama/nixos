---
stato: bozza
---

# Cicli autonomi

Il ciclo autonomo è il ciclo congiunto `eval all → exec all → commit` di un
repo (skill `/cycle`), lanciato da un'unità utente con un agente non
interattivo, senza custode. Scelta e gradini vivono in method (filo
`i3/ciclo-autonomo.md`); qui c'è il meccanismo che li porta sugli host.

## Decisioni e meccanismo

- **`o3/cicli.nix`**, le decisioni: per ogni repo host, checkout, cadenza e
  orario, stato (`manuale`, `timer`) e recinto. Un solo `host` per repo: un
  solo host tiene il ciclo autonomo di un repo per costruzione. I cicli che
  girano sugli host di lavoro li dichiara il repo `example-org/nixos-ufficio`.
- **`o3/modules/home/cicli.nix`**, il meccanismo: importato da tutti i
  profili in `o3/home/default.nix`, genera `ciclo-<repo>.service` e la sua
  sonda solo dove `host` coincide con l'`hostname` del profilo, e il
  `.timer` solo in stato `timer`. Pubblica anche il quadro completo in
  `~/.local/state/ciclo/decisioni.json`.
- **`o3/modules/home/ciclo/registry.nix`**, il lettore condiviso da cicli e
  presentazioni: applica i default (`giri = i1/giri`, `canone = method`, il
  paracadute), così il registro dichiara soltanto le eccezioni.

Confine: `nixos` decide dove e quando, il repo decide cosa. Branch, prompt,
permessi, minuti, budget e motori sono file del repo in `o3/ciclo/`
(`lanciatore.toml`, `prompt.md`, `permessi.json`), e il registro non ne
tiene nessuno. Un nuovo adottante deve avere quei file e la cartella dei
giri ignorata da Git prima di attivare il ciclo, altrimenti il lanciatore si
ferma con codice `14`.

Unità utente, non di sistema: il lingering è attivo su `deck`, lo switch è
home-level, e l'unità trova nella home le credenziali di Claude
(`~/.claude/.credentials.json`) e la chiave ssh senza passphrase, usata con
`BatchMode` e senza agent. Claude e Codex sono i pacchetti di `pkgs-ai`
fissati nel modulo, non quelli del profilo.

Ciò che vale per tutte le sessioni lo passa l'unità, perché
`--setting-sources project` salta `~/.claude/settings.json`: le variabili
d'ambiente stanno in `Environment`. L'`attribution` vuota la fonde il
lanciatore nei permessi del giro, in `.git/lanciatore/settings.json`: senza
la fusione il commit del giro porterebbe il trailer `Co-Authored-By`.

## Lanciatore canonico

Ogni ciclo gira col lanciatore di method: l'unità esterna `ciclo-<repo>`,
senza namespace, lancia `o3/lanciatore.py` dal checkout del canone
(`canone`, default `method`) con Python, Claude e Codex fissati da Nix
(`--claude`, `--codex`). Il lanciatore viene dal checkout vivo, non da una
versione fissata, e deve conoscere `--recinto-ferma`.

Sono del lanciatore: controllo delle sessioni, lock e `settings.json` in
`.git/lanciatore/`, pull, righe `partenza` e `chiusura` nella cartella dei
giri. Restano all'unità `ciclo-fetch` e la `StateDirectory` (`fetch.json`,
`sonde.jsonl`).

Solo l'agente sta nel recinto, passato con `--recinto`: un'unità transitoria
`ciclo-<repo>-agente` di `systemd-run --user --wait --pipe`, con ambiente e
proprietà scritti con percorsi letterali, perché `systemd-run` non espande
gli specificatori. Tre condizioni la tengono legata all'unità esterna:

- `BindsTo` e `After` verso `ciclo-<repo>.service` e
  `--expand-environment=no`: senza, al tetto di tempo unità e agente
  restano vivi;
- `--recinto-ferma`: il lanciatore ferma l'unità dell'agente dopo ogni
  agente, anche a uscita normale, prima di scrivere la chiusura. Un'uscita
  diversa da 0 è il codice `25` con `fermo` persistente, e i giri seguenti
  escono con `24` finché il custode non lo toglie;
- lo stop è `ciclo-recinto-ferma`
  (`o3/modules/home/ciclo/ciclo-recinto-ferma.sh`), non un semplice stop
  di `systemctl --user`: `--collect` scarica l'unità appena l'agente esce e
  lo stop risponderebbe `5`. Lo script accetta il `5` solo con l'unità
  `not-found`, vuole lo stato `inactive` o `failed` e il cgroup in
  `app.slice` assente o vuoto.

Tempi. Minuti e budget sono del profilo del repo (default 45 minuti, 5 USD
e solo Claude). Sopra, l'host tiene un solo paracadute fisico uguale per
tutti (`registry.nix`): agente 85 minuti, unità esterna 90, che la vista usa
anche per il ritardo di chiusura (`decisioni.json`). Un profilo oltre gli 80
minuti chiede di alzarlo. L'unità esterna ha `TimeoutStopSec=90s`, l'agente
`30s`: al tetto `RuntimeMaxSec` il SIGTERM arriva al lanciatore, che ferma
l'agente e lo attende; con `30s` anche fuori, un agente che ignora il
SIGTERM porterebbe via il lanciatore prima della chiusura. Con uno stop a
mano dell'unità esterna il margine non serve, perché per `After=` systemd
ferma prima l'agente.

Due comportamenti da conoscere:

- due lanciatori avviati nello stesso istante falliscono entrambi il pull
  del canone `~/method`; i timer non si sovrappongono, il caso riguarda
  solo gli avvii a mano;
- la chiusura riporta `commit: true` quando `HEAD` cambia durante il giro,
  anche se il commit è di una sessione del custode: il lanciatore legge il
  cambio di `HEAD`, non chi ha committato. L'avviso del giro dice chi.

### Quota e fallback

La chiusura porta `engine`, `engine_attempts` con l'osservazione del
provider di ogni tentativo e `costo_usd` cumulato: un rifiuto per quota
esaurita resta leggibile in `tentativi.jsonl`.

Il motore lo sceglie il repo, con `motori` nel proprio profilo (per esempio
`["claude", "codex"]`, anche al contrario), e lo accende dopo un primo giro
a mano col custode. Il secondo subentra una volta sola, se il primo è
indisponibile prima di qualunque atto. Codex passa dall'esecutore canonico
`o3/esecutore_codex.py` di method, che traduce `permessi.json` e l'hook sul
commit; senza tetto in USD la chiusura dichiara `budget_usd_imposto: false`.
Con Codex il contratto canonico `--recinto-host` usa il solo recinto
dell'host (`i2/codex-recinto-host.md`).

La parte dell'host: lo script `lancia` passa `--codex` col binario di
`pkgs-ai`, e il recinto ha `~/.codex` scrivibile (sessioni, rinnovo di
`auth.json`). In `nixos` Claude è primo e Codex di riserva.

## Recinto

Nell'unità dell'agente la home è in sola lettura e restano scrivibili il
checkout, la cartella di stato, `~/.claude`, `~/.claude.json`, `~/.codex` e
i path che il repo dichiara; i path inaccessibili si dichiarano per repo.
`RuntimeMaxSec`, `NoNewPrivileges`, `GIT_TERMINAL_PROMPT=0`,
`GIT_SSH_COMMAND="ssh -o BatchMode=yes"`. L'unità esterna è `Type=exec` (su
`oneshot` `RuntimeMaxSec` non ha effetto), quindi `systemctl --user start`
torna subito.

Il lettore aggiunge ai `readOnlyPaths`, anche con `homeWritable`, ciò che il
giro non deve modificare: `<checkout>/o3/ciclo` e ciò che git esegue dal
lanciatore fuori dal recinto, cioè `o3/lanciatore.py` e
`o3/esecutore_codex.py` del canone, `.git/config`, `.git/hooks` e
`.git/lanciatore` del checkout.

`nixos` dichiara `homeWritable`, perché lo switch di `/manutenzione` rilinka
file in tutta la home: il suo recinto sono i percorsi protetti qui sopra e i
permessi del giro, che negano la scrittura su `CLAUDE.md`, `AGENTS.md`,
`autonomy.md`, `.claude/`, `.codex/` e `o3/ciclo/`.

Sui mount FUSE il recinto vale per sottocartella: in `salute` la sonda trova
`gdrive-personale` in sola lettura e `gdrive-personale/salute` scrivibile.

I wrapper di comando (`wrappers` in `cicli.nix`) stanno in testa al `PATH`
dell'unità e aggiungono sempre gli argomenti dichiarati: in `salute` ed
`economia`, `gog` riceve `--gmail-no-send`. Fermano alias e chiamate
distratte, non una chiamata col path assoluto del binario reale.

## Account degli altri su deck

Su `deck` il keyring di `gog` non ha altri account e mancano alias e chiave
GitHub di familiare. Il Drive di familiare è un mount privato: il suo token
sta in `~/.config/rclone-gdrive-familiare/rclone.conf`, non nel
`rclone.conf` condiviso che i cicli usano, e quel file e il mount sono fra
gli `InaccessiblePaths` di ogni ciclo, aggiunti dal modulo (`privatePaths`
in `o3/modules/home/cicli.nix`) e controllati dalla sonda. Così l'accesso
via API, che un path inaccessibile da solo non fermerebbe, resta senza
credenziali dentro l'unità. Lo stream del giro resta la traccia di un
aggiramento.

## Avvio e arresti

I controlli prima dell'agente e i codici di uscita sono del lanciatore
(docstring di method `o3/lanciatore.py`): fra gli altri `75` lock, `10`
working tree sporco, `11` branch, `14` profilo o file del ciclo mancanti,
`15` sessione concorrente, `23` percorsi protetti toccati, `24` `fermo`
presente, `25` arresto del recinto non verificato. Senza mai merge, rebase
o stash; il commit e il push li fa il giro.

Un namespace che systemd non riesce a preparare (`226`, per esempio un path
di `readWritePaths` su un mount Drive in I/O error) ferma l'unità prima di
qualunque script nel recinto.

## Sessioni concorrenti

Le sessioni aperte non si controllano prima del giro ma al commit: una
sessione Claude o Codex lasciata aperta e inattiva nel checkout è innocua e
non ferma il ciclo; conta solo una che lavora mentre il giro gira, perché il
commit del giro potrebbe portarsi dietro le sue modifiche.

Il controllo legge i transcript e non i processi, perché dentro il namespace
dell'unità `/proc/<pid>/cwd` degli altri processi è negato. Davanti al
commit del giro `lanciatore.py` cerca i transcript con attività dopo la
partenza:

- `~/.claude/projects/<checkout codificato>/*.jsonl` (ogni carattere non
  alfanumerico del path diventa `-`; il giro non ne lascia di suoi);
- `~/.codex/sessions/**/rollout-*.jsonl` con la cwd della `session_meta` nel
  checkout (le sessioni Codex sono thread del daemon `app-server`, la cui
  cwd è dove è nato: `/proc` non le vede).

Se ne trova, blocca il commit e chiude con `15 sessione-concorrente`; il
tree resta sporco e il giro successivo si ferma su `10` finché il custode
non riconcilia. Una sessione che scrive solo dopo il commit del giro trova
il commit già fatto, come dopo un pull.

Il timestamp di modifica è solo un prefiltro: si leggono gli ultimi 4 MiB
dal fondo fino al primo evento con timestamp non successivo alla partenza.
Conta solo una chiamata a uno strumento: per Claude un evento `assistant`
con `tool_use` in `message.content`; per Codex un `response_item` con
`payload.type` che finisce in `_call`. Testo, output degli strumenti ed
eventi senza timestamp valido non contano.

La sessione che avvia il giro può quindi scrivere la risposta dopo la
partenza senza bloccarlo. Una chiamata successiva a uno strumento conta
ancora, anche per leggere `journalctl` o `systemctl status`, o per aspettare
la fine: il giro a mano si lancia da un terminale separato, o dalla sessione
come ultimo atto, e le sessioni del checkout restano ferme finché non
finisce. L'avvio differito resta disponibile come margine operativo:

```bash
systemd-run --user --on-active=120s --collect systemctl --user start ciclo-economia
```

## Esito dei tentativi

Le tracce le scrive il lanciatore nella cartella `giri` del checkout
(canone `i1/giri`, ignorata da git), dove il giro può riscriverle: il
custode ha accettato che stiano nel suo perimetro.

- `tentativi.jsonl`: righe `partenza` e `chiusura` per tentativo. La
  chiusura porta esito, motivo, codice, motore (`engine`,
  `engine_attempts`), commit del giro e degli altri, push, `oggetto`, tree
  sporco dopo, dinieghi, costo e durata; il contratto è in method
  `o3/ciclo/fallback.md`;
- `giri/<id>.jsonl`: lo stream dell'agente, un evento per riga, ogni
  comando del giro compreso: rende leggibile dopo un aggiramento del
  recinto. Mai pubblicati;
- `ultimo.json`: l'ultima chiusura.

`SERVICE_RESULT=success` da solo non prova che il giro sia riuscito: va
letta la chiusura.

## Nella vista

La home del repo mostra gli ultimi tentativi col semaforo e una pagina per
giro: il `serve.py` del checkout legge lo stato a ogni richiesta, sotto
`/_ciclo/`. `o3/modules/home/presentations.nix` passa alla vista pubblicata
di un repo il cui ciclo gira sullo stesso host `--ciclo-state` con la
cartella `giri` del checkout e `--ciclo-unita %S/ciclo/<repo>` per le
decisioni. Il flag è passato senza controllare il `serve.py`: uno che non
conosce l'opzione fa fallire il server con l'errore di argparse nel journal.

Ciclo autonomo e vista dello stesso repo stanno sullo stesso host:
un'assertion del modulo `cicli` fa fallire la build home dell'host del ciclo
se il repo ha una vista permanente in `presentations.nix` che quell'host non
serve.

## Sonda

`ciclo-<repo>-sonda` lancia `lanciatore.py --controlli`, in sola lettura e
fuori da ogni namespace come il lanciatore: niente fetch né pull, mai
l'agente. Poi `ciclo-recinto`, in un'unità transitoria
`ciclo-<repo>-sonda-recinto` col recinto dell'agente, prova il recinto con
`test -r`/`test -w`, senza scrivere: home e `readOnlyPaths` in sola lettura,
checkout, stato e `readWritePaths` scrivibili, `inaccessiblePaths`
illeggibili. Esito in `sonde.jsonl`, separato dai tentativi. Una sessione
aperta (`15`) con un recinto sano chiude la sonda con codice `0`.

## Atti remoti

Da `deck` l'agente raggiunge `game` e `neve` solo con `remoto`
(`o3/modules/home/remoto.nix`, criterio `atti-remoti` di `autonomy.md`). I
comandi remoti sono fissati nello script costruito da Nix, che il giro non
può modificare; `ssh` resta negato nel giro. Il giro notturno non lo usa:
alle 04:30 `game` e `neve` sono spenti. `remoto` rifiuta gli host di lavoro, che
vivono nel repo `example-org/nixos-ufficio`.

- `remoto stato <host>`: `nixos-version`, generazioni di sistema e home (la
  riga `home:` è l'input di `o3/scripts/home-drift.sh`), revisione e
  toplevel del sistema attivo (righe `revisione:` e `sistema:`, input di
  `o3/scripts/system-drift.sh`), albero inviato, `HEAD` e stato di
  `~/nixos`, unità fallite di sistema e utente, e
  `~/.local/state/nixos/home.json`: i rev degli input della home attiva e
  la versione di `gogcli` dove è installato, scritti da `stato-home.nix` a
  ogni switch, di chiunque. È il fatto da cui `/manutenzione` certifica
  `applicato_su`. Sola lettura.
- `remoto allinea <host>`: manda l'albero dell'index di `deck` (con
  `git write-tree`, poi `git archive`) in `~/.cache/remoto/nixos` sull'host
  e ci fa lo switch Home Manager del profilo dell'host, con
  `o3/scripts/con-identita.sh` e il flake `path:` di quella cartella,
  registrando l'albero in `~/.cache/remoto/albero`. È idempotente: un
  albero già applicato non si rimanda. Quando l'`HEAD` di `deck` porta
  quell'albero ed è su `origin`, fa anche `git pull --ff-only` di `~/nixos`
  sull'host.

Codici di uscita: `0` riuscito, `2` uso (anche un host di lavoro), `3` host non
raggiungibile, `6` su `deck` ci sono file non in staging (l'albero inviato
non sarebbe quello dello switch di `deck`); dopo uno switch riuscito, `10`
checkout remoto sporco, `11` branch remoto non `main`, `12` `HEAD` remoto
diverso dopo il pull, `13` pull fallito: lo switch vale, è solo il checkout
a restare indietro. Altrimenti il codice del comando remoto.

Il gate confronta l'albero, non la generazione: un commit di soli testi
richiede un nuovo `allinea` anche quando la home non cambia. Lo switch
dall'albero inviato dà la stessa generazione dello switch dal checkout:
`path:` e `git` costruiscono la stessa home.

## Uso

```bash
systemctl --user start ciclo-salute-sonda   # controlli e recinto, senza Claude
systemctl --user start ciclo-salute         # avvio a mano, fuori cadenza
systemctl --user start --wait ciclo-salute  # idem, e aspetta la fine
systemctl --user list-timers 'ciclo-*'      # prossima partenza
journalctl --user -fu ciclo-salute
jq . ~/salute/i1/giri/ultimo.json
```

Orari, gradini e il motivo di ogni spostamento vivono accanto alle
decisioni, nei commenti di `o3/cicli.nix`: nixos alle 04:30, salute alle
09:00, economia alle 14:00 e method per ultimo alle 15:00, perché il suo
perceive trovi i giri degli adottanti del giorno. Tutti al gradino 1.

I timer hanno `Persistent=false`. Se `deck` è spento all'orario, il giro non
recupera all'avvio e dopo un'ora la home lo segna rosso come partenza
mancata, ed è vero. Se `deck` è sospeso, systemd fa partire il timer scaduto
alla ripresa (con `Persistent` o senza), e quella partenza tardiva spegne il
rosso.

Prompt e criterio `ciclo-autonomo` cambiano gradino insieme al timer, perché
il giro si firmi col gradino giusto. Uno switch Home Manager eseguito dal
giro non riavvia l'unità del giro stesso.

## Permessi del giro

Con `--setting-sources project` il `.claude/settings.json` del repo si fonde
con il file del ciclo. I deny valgono anche contro un allow del ciclo; gli
allow valgono se il workspace è fidato (`hasTrustDialogAccepted`, che non
passa alle sottocartelle), altrimenti Claude li ignora con un avviso. Con
`--setting-sources ""` il file del ciclo resta l'unico, ma il giro perde
`CLAUDE.md` e le skill del progetto: non è usabile.

Regola che ne segue: gli allow del `.claude/settings.json` di un repo con
ciclo autonomo stanno dentro quelli dei permessi del giro
(`o3/ciclo/permessi.json`); i deny vi si possono aggiungere liberamente.

## Grafie dei permessi

`o3/scripts/sonda-grafie.sh` lancia `claude -p` con il `settings.json` fuso
del giro (`.git/lanciatore/`) e le sue opzioni di permesso
(`--setting-sources project`, `--permission-mode dontAsk`), una prova per
forma di comando. Ogni forma è innocua ed è composta solo da comandi in
allow: un diniego dipende quindi dalla grafia, non dal contenuto. Una prova
di controllo in deny (`find`) deve uscire negata. Si lancia in sessione col
custode quando il ramo `ia` porta una nuova versione di Claude Code. Il giro
non la lancia, perché `claude -p` lì è negato. Gli esiti si accumulano in
`i1/grafie-permessi.jsonl`, una tornata per versione, circa 0,11 USD a
prova.

La lettura corrente degli esiti, cioè quali forme sono negate e quali
concesse sulla versione provata e le cause dei dinieghi osservati nei giri,
vive in `i2/grafie-permessi.md` e si aggiorna a ogni tornata.

La regola delle grafie della skill `cycle` (uno per chiamata, niente `;`,
`&&`, `for`, graffe, heredoc) è più stretta del necessario su `;`, `&&` e
heredoc da soli, ma resta corretta: evita tutti i casi negati. Allargarla
spetta al canone di `method`.

## Da verificare

- rimontaggio del Drive durante un giro, e un namespace dell'agente che
  fallisce (`226` sull'unità transitoria): come lo chiude il lanciatore non
  è ancora visto in un fallimento reale;
- il tetto di tempo è provato solo su unità transitorie, non in un giro
  vero;
- il fallback per credito davvero esaurito non è ancora accaduto.

Connessioni:

- [home-manager](home-manager.md)
- [rclone-gdrive](rclone-gdrive.md)
- [secrets-management](secrets-management.md)
