---
stato: bozza
---

# Cicli autonomi

Il ciclo autonomo è il ciclo congiunto `eval all → exec all → commit` di un repo
(skill `/cycle`), lanciato da
un'unità utente con Claude Code non interattivo, senza custode. Scelta e
gradini vivono in method (`o2/dove-gira-il-ciclo-autonomo.md`,
`o2/pilota-ciclo-autonomo.md`); qui c'è il meccanismo che li porta sugli host.

## Decisioni e meccanismo

- **`o3/cicli.nix`**, le decisioni: per ogni repo host, checkout, cadenza e
  orario, stato (`manuale`, `timer`, `esterno`) e recinto. Un solo `host`
  per repo: un solo host tiene il ciclo autonomo di un repo per
  costruzione. I cicli di `bi` e `baserow` su `svezia` e `danea-auto` (Task
  Scheduler) li dichiara il repo `example-org/nixos-ufficio`.
- **`o3/modules/home/cicli.nix`**, il meccanismo: importato da tutti i
  profili in `o3/home/default.nix`, genera `ciclo-<repo>.service` e la sua
  sonda solo dove `host` coincide con l'`hostname` del profilo, e il
  `.timer` solo in stato `timer`. Pubblica anche il quadro completo in
  `~/.local/state/ciclo/decisioni.json`.

Confine: `nixos` decide dove e quando, il repo decide cosa. Ogni ciclo gira
col lanciatore canonico di method (sezione «Lanciatore canonico»): branch,
prompt, permessi, minuti, budget e motori sono file del repo in
`o3/ciclo/` (`lanciatore.toml`, `prompt.md`, `permessi.json`), e il registro
non ne tiene nessuno; `registry.nix` fallisce la valutazione se ne trova
uno. Il lettore condiviso `o3/modules/home/ciclo/registry.nix` applica a
cicli e presentazioni i default (`giri = i1/giri`, `canone = method`, il
paracadute); il registro dichiara soltanto le eccezioni. Le voci `esterno`,
prive di checkout, restano fuori dai default NixOS.

Il lettore aggiunge ai `readOnlyPaths`, senza duplicati e anche con
`homeWritable`, `<checkout>/o3/ciclo` e ciò che git esegue dal lanciatore
fuori dal recinto: il giro non modifica le proprie istruzioni.
`decisioni.json` pubblica le decisioni esplicite del registro col
paracadute come `maxRuntime`. I nuovi adottanti devono avere i file del
ciclo e la cartella giri ignorata da Git prima di attivare il ciclo,
altrimenti il lanciatore si ferma con codice `14`.

Ciò che vale per tutte le sessioni lo passa l'unità, perché `--setting-sources
project` salta `~/.claude/settings.json`: le variabili d'ambiente in
`Environment`. L'`attribution` vuota (decisione del custode del 2026-10-11,
method `e5a57bb`) la fonde il lanciatore stesso nei permessi del giro, in
`.git/lanciatore/settings.json`. Verificato su claude 2.1.295 in `-p`:
senza la fusione il commit porta il trailer `Co-Authored-By`, con la
fusione no.

Unità utente, non di sistema: il lingering è attivo su `deck`,
lo switch è home-level, e l'unità trova nella home le credenziali di Claude
(`~/.claude/.credentials.json`) e la chiave ssh senza passphrase, usata con
`BatchMode` e senza agent. Claude e Codex sono i pacchetti di `pkgs-ai`
fissati nel modulo, non quelli del profilo.

## Recinto

Il recinto vero è l'unità transitoria dell'agente: la home è in sola
lettura e restano scrivibili il checkout, la cartella di stato, `~/.claude`,
`~/.claude.json`, `~/.codex` e i path che il repo dichiara; i path
inaccessibili si dichiarano per repo. `RuntimeMaxSec`, `NoNewPrivileges`,
`GIT_TERMINAL_PROMPT=0`, `GIT_SSH_COMMAND="ssh -o BatchMode=yes"`. L'unità
esterna è `Type=exec` (su `oneshot` `RuntimeMaxSec` non ha effetto), quindi
`systemctl --user start` torna subito.

I wrapper di comando (`wrappers` in `cicli.nix`) stanno in testa al `PATH`
dell'unità e aggiungono sempre gli argomenti dichiarati: in `salute`, `gog`
riceve `--gmail-no-send`. Fermano alias e chiamate distratte, non una chiamata
col path assoluto del binario reale.

## Account degli altri su deck

Su `deck` nessun altro account nel keyring di `gog` e niente alias e chiave
GitHub di familiare (custode, 2026-10-11: «semplifichiamo e ripuliamo»). Il
Drive di familiare è tornato su deck il 2026-11-07 come mount privato: il suo
token sta in `~/.config/rclone-gdrive-familiare/rclone.conf`, non nel
`rclone.conf` condiviso che i cicli usano, e quel file e il mount sono fra
gli `InaccessiblePaths` di ogni ciclo, aggiunti dal modulo (`privatePaths`
in `o3/modules/home/cicli.nix`) e controllati dalla sonda. Così l'accesso
via API, che un path inaccessibile da solo non fermerebbe, resta senza
credenziali dentro l'unità. Lo stream del giro resta la traccia di un aggiramento.

## Avvio e arresti

I controlli prima dell'agente e i codici di uscita sono del lanciatore
(docstring di method `o3/lanciatore.py`): fra gli altri `75` lock, `10`
working tree sporco, `11` branch, `14` profilo o file del ciclo mancanti,
`15` sessione concorrente, `23` percorsi protetti toccati, `24` `fermo`
presente, `25` arresto del recinto non verificato. Senza mai merge, rebase
o stash; il commit e il push li fa il giro.

Fino al 2026-11-11 i cicli di salute, economia e nixos avevano un percorso
proprio dell'host (`ciclo-avvio`, `ciclo-chiusura`, `ciclo-namespace`,
l'hook `ciclo-concorrenti`), rimosso quando tutti e quattro sono passati
al lanciatore; la sua storia è in git. Fra le lezioni che ha lasciato:
un namespace che systemd non riesce a preparare (`226`, un path di
`readWritePaths` su un mount Drive in I/O error, 2026-10-14,
`i1/ciclo-salute-namespace-20261014.md`) ferma l'unità prima di qualunque
script nel recinto.

## Atti remoti

Da `deck` l'agente raggiunge `game` e `neve` solo con `remoto`
(`o3/modules/home/remoto.nix`, criterio `atti-remoti` di `autonomy.md`, dal
2026-10-19). I comandi remoti sono fissati nello script costruito da Nix,
che il giro non può modificare; `ssh` resta negato nel giro. Il giro
notturno non lo usa: alle 04:30 `game` e `neve` sono spenti, e
`remoto` rifiuta i server, che vivono nel repo `example-org/nixos-ufficio`.

- `remoto stato <host>`: `nixos-version`, generazioni di sistema e
  home (la riga `home:` è l'input di `o3/scripts/home-drift.sh`),
  revisione e toplevel del sistema attivo (righe `revisione:` e `sistema:`, input di `o3/scripts/system-drift.sh`), albero inviato, `HEAD` e stato di `~/nixos`, unità fallite di
  sistema e utente, e `~/.local/state/nixos/home.json`: i rev degli input
  della home attiva e la versione di `gogcli` dove è installato, scritti
  da `stato-home.nix` a ogni switch, di chiunque. È il fatto da cui
  `/manutenzione` certifica `applicato_su`. Sola lettura.
- `remoto allinea <host>`: manda l'albero dell'index di `deck` (`git
write-tree`, poi `git archive`) in `~/.cache/remoto/nixos` sull'host e ci
  fa `o3/scripts/con-identita.sh home-manager switch --flake path:...#$USER@$(hostname)`, registrando
  l'albero in `~/.cache/remoto/albero`. È idempotente: un albero già
  applicato non si rimanda. Quando l'`HEAD` di `deck` porta quell'albero ed
  è su `origin`, fa anche `git pull --ff-only` di `~/nixos` sull'host.

Codici di uscita: `0` riuscito, `2` uso (anche un server), `3` host non
raggiungibile, `6` su `deck` ci sono file non in staging (l'albero inviato
non sarebbe quello dello switch di `deck`); dopo uno switch riuscito, `10`
checkout remoto sporco, `11` branch remoto non `main`, `12` `HEAD` remoto
diverso dopo il pull, `13` pull fallito: lo switch vale, è solo il checkout
a restare indietro. Altrimenti il codice del comando remoto.

Il gate confronta l'albero, non la generazione: un commit di soli testi
richiede un nuovo `allinea` anche quando la home non cambia. Collaudo del
2026-10-19: lo switch dall'albero inviato ha dato la stessa generazione
(stesso path nello store) dello switch dal checkout, quindi `path:` e `git`
costruiscono la stessa home.

## Esito dei tentativi

Le tracce le scrive il lanciatore nella cartella `giri` del checkout
(canone `i1/giri`, ignorata da git), dove il giro può riscriverle: il
custode ha accettato che stiano nel suo perimetro. Lock e `settings.json`
fuso stanno in `.git/lanciatore/`; la `StateDirectory` dell'unità tiene
`fetch.json` e `sonde.jsonl`.

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
giro (prescrizione method `ciclo-autonomo`): il `serve.py` del checkout
legge lo stato a ogni richiesta con `--ciclo-state`, sotto `/_ciclo/`.
`o3/modules/home/presentations.nix` passa `--ciclo-state
%S/ciclo/<repo>` (o la cartella `giri` del checkout, con `--ciclo-unita
%S/ciclo/<repo>` per le decisioni quando `giri` non è null) alla vista pubblicata di un repo il cui ciclo autonomo gira sullo
stesso host. Il flag è passato senza controllare il `serve.py`: il fallback
per i repo che non avevano ancora recepito il canone è stato tolto il
2026-10-15, quando salute e crm l'avevano recepito. Un `serve.py` senza
l'opzione fa fallire il server con l'errore di argparse nel journal.

Ciclo autonomo e vista dello stesso repo stanno sullo stesso host: un'assertion del
modulo `cicli` fa fallire la build home dell'host del ciclo se il repo ha
una vista permanente in `presentations.nix` che quell'host non serve.

## Lanciatore canonico

Dal 2026-11-08 `method` e dal 2026-11-11 `salute`, `economia` e `nixos`
girano col lanciatore canonico. Per `nixos`
il recinto dell'agente tiene la home scrivibile (`homeWritable`, lo switch
di `/manutenzione`) più i percorsi protetti del lanciatore; i permessi del
giro negano già la scrittura su quelli canonici (`CLAUDE.md`, `AGENTS.md`,
`autonomy.md`, `.claude/`, `.codex/`, `o3/ciclo/`). Per `method`: l'unità
esterna `ciclo-method`, senza namespace, lancia
`o3/lanciatore.py` dal checkout del canone (`canone`, default `method`) con
Python, Claude e Codex fissati da Nix (`--claude`, `--codex`). Sessioni, lock e `settings.json` in
`.git/lanciatore/`, pull, righe `partenza` e `chiusura` in `i1/giri/` sono del
lanciatore; restano all'unità `ciclo-fetch` e la `StateDirectory`
(`fetch.json`, `sonde.jsonl`). Minuti, budget e motori sono del profilo del
repo (`o3/ciclo/lanciatore.toml`, default 45 minuti, 5 USD e solo Claude):
dal 2026-11-11 (method `201a6eb`, prescrizione `motori-del-ciclo`) il
registro non tiene né `maxRuntime` né `agentMaxRuntime` né
`maxBudgetUsd`.

Solo l'agente sta nel recinto, passato con `--recinto`: un'unità transitoria
`ciclo-method-agente` di `systemd-run --user --wait --pipe`, con lo stesso
ambiente (`--setenv`, PATH compreso) e le stesse proprietà del recinto di
prima, scritte con percorsi letterali perché `systemd-run` non espande gli
specificatori. `BindsTo` e `After` verso `ciclo-method.service` e
`--expand-environment=no` sono le condizioni trovate dalle prove della
sessione di casa del 2026-11-08: senza, al tetto unità e agente restano vivi.
`--recinto-ferma` fa fermare l'unità interna al lanciatore prima di scrivere
la chiusura. Da method `accb3b5` lo stop gira dopo **ogni** agente, anche a
uscita normale, e un'uscita diversa da 0 è il codice `25`
(`recinto-arresto-non-verificato`) con `fermo` persistente: i giri seguenti
escono con `24` finché il custode non lo toglie. Un semplice `systemctl
--user stop` lì sbaglia, perché `--collect` scarica l'unità appena l'agente
esce e lo stop risponde `5`. Dal 2026-11-11 lo stop è `ciclo-recinto-ferma`
(`o3/modules/home/ciclo/ciclo-recinto-ferma.sh`): accetta il `5` solo con
l'unità `not-found`, vuole lo stato `inactive` o `failed` e il cgroup in
`app.slice` (esplicito nel recinto) assente o vuoto. Provato su unità
transitorie vere, uscita normale e unità viva, e su un `systemctl` finto
per i tre rifiuti. Sopra i minuti del profilo l'host tiene un solo
paracadute fisico, uguale per tutti i cicli
(`registry.nix`): agente 85 minuti, unità esterna 90, che la vista usa
anche per il ritardo di chiusura (`decisioni.json`). Un profilo oltre gli 80
minuti chiede di alzarlo.

L'unità esterna ha `TimeoutStopSec=90s`, l'agente `30s`: lo scheduler lascia
al lanciatore più tempo di quanto la sandbox ne lasci all'agente (method
`7a8d57e`). Con uno `systemctl --user stop ciclo-method` non servirebbe: per
`After=` systemd ferma prima l'agente e manda il SIGTERM al lanciatore solo
dopo. Al tetto `RuntimeMaxSec` dell'unità esterna invece il SIGTERM arriva
subito al lanciatore, che ferma l'agente e lo attende. Prova del 2026-11-08 su
`svezia`, con unità transitorie, un repo usa e getta e un agente finto che
ignora il SIGTERM: con `30s` al tetto il lanciatore muore col SIGKILL e resta
la sola `partenza`. Con `90s` la chiusura arriva dopo la morte dell'agente: `143`
interrotto, oppure `23` se l'agente finto ha committato in `o3/ciclo/`, sia al
tetto sia allo stop.

Collaudato su `deck` con sonda e giro a mano: `method` il 2026-11-08, gli
altri tre il 2026-11-11, senza `fermo` e senza che l'unità dell'agente
restasse in vita. Il tetto di tempo è provato solo su unità transitorie.

Il recinto aggiunge in sola lettura ciò che git esegue dal lanciatore fuori
dal recinto: `o3/lanciatore.py` e, da method `de73101`,
`o3/esecutore_codex.py` del canone, `.git/config`, `.git/hooks` e
`.git/lanciatore` del checkout (criterio di method `477b442`). Il lanciatore
dev'essere almeno a `477b442`, che introduce `--recinto-ferma`.

La sonda `ciclo-method-sonda` è `lanciatore.py --controlli`, fuori da ogni
namespace come il lanciatore, più `ciclo-recinto` in un'unità transitoria
`ciclo-method-sonda-recinto` col recinto dell'agente. Una sessione aperta
(`15`) con un recinto sano salta la sonda con codice `0`. La riduzione
della sonda è una proposta della sessione di casa: la decide il custode.

Due lezioni dai collaudi di `salute` ed `economia` del 2026-11-11:

- due lanciatori avviati nello stesso istante falliscono entrambi il pull
  del canone `~/method`, che da solo riesce; i timer non si sovrappongono,
  il caso riguarda solo gli avvii a mano;
- la chiusura riporta `commit: true` quando `HEAD` cambia durante il giro,
  anche se il commit è di una sessione del custode: il lanciatore legge il
  cambio di `HEAD`, non chi ha committato. L'avviso del giro dice chi.

### Quota e fallback

Da method `fce8afe` la chiusura porta `engine`, `engine_attempts` con
l'osservazione del provider di ogni tentativo e `costo_usd` cumulato: un
rifiuto per quota esaurita resta leggibile in `i1/giri/tentativi.jsonl` di
ogni ciclo.

Da method `201a6eb` il motore lo sceglie il repo, con `motori` nel proprio
profilo (per esempio `["claude", "codex"]`, anche al contrario). Il secondo
subentra una volta sola, se il primo è indisponibile prima di qualunque
atto. Codex passa dall'esecutore canonico `o3/esecutore_codex.py` di
method, che traduce `permessi.json` e l'hook sul commit; senza tetto in USD
la chiusura dichiara `budget_usd_imposto: false`. La parte dell'host su
`deck`: lo script `lancia` passa `--codex` col binario di `pkgs-ai`, e il
recinto dei cicli ha `~/.codex` scrivibile (sessioni, rinnovo di
`auth.json`). Con Codex il contratto canonico `--recinto-host` usa il solo
recinto dell'host (`i2/codex-recinto-host.md`).

Il secondo motore si accende repo per repo nel suo profilo, dopo un primo
giro a mano col custode. In `nixos` è acceso di riserva dal 2026-11-11, con
Claude primo; giri a mano con Codex primo riusciti lo stesso giorno in
method e in nixos, fino al push. Il fallback per credito davvero esaurito
non è ancora accaduto: da riaprire se quando accade qualcosa non va.

## Sessioni concorrenti

Le sessioni aperte non si controllano prima del giro ma al commit (custode,
2026-11-10): una sessione Claude o Codex lasciata aperta e inattiva nel
checkout è innocua e non deve fermare il ciclo; conta solo una che lavora
mentre il giro gira, perché il commit del giro potrebbe portarsi dietro le
sue modifiche. Prima il controllo stava prima del lock: un processo Claude
con la cwd nel checkout, o un rollout Codex scritto negli ultimi 60
minuti, fermavano il giro (economia, 2026-11-10 alle 14:00: una sessione
Codex ferma dalle 13:34 ha fatto saltare il giro).

Lo fa `lanciatore.py`: davanti al commit del giro cerca i transcript con
attività dopo la partenza, cioè

- `~/.claude/projects/<checkout codificato>/*.jsonl` (ogni carattere non
  alfanumerico del path diventa `-`; il giro non ne lascia di suoi);
- `~/.codex/sessions/**/rollout-*.jsonl` con la cwd della `session_meta` nel
  checkout (le sessioni Codex sono thread del daemon `app-server`, la cui
  cwd è dove è nato: `/proc` non le vede).

Se ne trova, blocca il commit e chiude con `15 sessione-concorrente`; il
tree resta sporco e il giro successivo si ferma su `10` finché il custode
non riconcilia. Una sessione che scrive solo dopo il commit del giro trova
il commit già fatto, come dopo un pull.

Il timestamp di modifica è solo un prefiltro (method `18a9f5a`): si leggono
gli ultimi 4 MiB dal fondo fino al primo evento con timestamp non
successivo alla partenza. Conta solo una chiamata a uno strumento: per
Claude un evento `assistant` con `tool_use` in `message.content`; per
Codex un `response_item` con `payload.type` che finisce in `_call`. Testo,
output degli strumenti ed eventi senza timestamp valido non contano.

La sessione che avvia il giro può quindi scrivere la risposta dopo la
partenza senza bloccarlo. Una successiva chiamata a uno strumento conta ancora,
anche per leggere `journalctl` o `systemctl status`, o per aspettare la fine:
il giro a mano si lancia da un terminale separato, o dalla sessione come
ultimo atto, e le sessioni del checkout restano ferme finché non finisce
(method `4728913`). Al collaudo di Codex in `nixos` del 2026-11-11 tre
tentativi si sono fermati così, sulla sessione del custode che controllava
il giro. L'avvio differito resta disponibile come margine
operativo, ma non serve per la sola risposta testuale:

```bash
systemd-run --user --on-active=120s --collect systemctl --user start ciclo-economia
```

## Sonda

`ciclo-<repo>-sonda` lancia `lanciatore.py --controlli`, in sola lettura,
niente fetch né pull, mai l'agente; poi `ciclo-recinto` in un'unità
transitoria col recinto dell'agente prova il recinto con `test -r`/`test
-w`, senza scrivere: home e `readOnlyPaths` in sola lettura, checkout,
stato e `readWritePaths` scrivibili, `inaccessiblePaths` illeggibili. Esito
in `sonde.jsonl`, separato dai tentativi.

## Uso

```bash
systemctl --user start ciclo-salute-sonda   # controlli e recinto, senza Claude
systemctl --user start ciclo-salute         # avvio a mano, fuori cadenza
systemctl --user start --wait ciclo-salute  # idem, e aspetta la fine
systemctl --user list-timers 'ciclo-*'      # prossima partenza
journalctl --user -fu ciclo-salute
jq . ~/salute/i1/giri/ultimo.json
```

Orari, gradini e il motivo di ogni spostamento vivono accanto alle decisioni,
nei commenti di `o3/cicli.nix`: nixos alle 04:30, salute alle 09:00, economia
alle 14:00 e method per ultimo alle 15:00, perché il suo perceive trovi i
giri degli adottanti del giorno. Tutti al gradino 1.

I timer hanno `Persistent=false`. Se `deck` è spento all'orario, il giro non
recupera all'avvio e dopo un'ora la home lo segna rosso come partenza
mancata, ed è vero. Se `deck` è sospeso, systemd fa partire il timer scaduto
alla ripresa (con `Persistent` o senza), e quella partenza tardiva spegne il
rosso. Una sessione Claude o Codex aperta nel checkout non ferma il giro; ne
blocca il commit solo se lavora mentre il giro gira (codice 15).

Prompt e criterio `ciclo-autonomo` passano al gradino 1 insieme al timer,
perché il giro si firmi col gradino giusto (regola nata dal primo giro
schedulato di economia). Uno switch Home Manager eseguito dal giro non
riavvia l'unità del giro stesso (giro di nixos del 2026-10-18, con bump e
switch veri).

## Esiti del gradino 0 e delle sonde

Su `deck`, 2026-10-11, salute:

- **giro riuscito** (commit `2eb8a69` in salute, push via ssh senza agent,
  1,85 USD, 4,5 minuti): `/eval`, `/exec` e `/commit` invocate davvero da
  `claude -p`, keyring di `gog` leggibile;
- **recinto sui mount FUSE**: la sonda trova `gdrive-personale` in sola lettura
  e `gdrive-personale/salute` scrivibile;
- **controllo `15`**: dentro il namespace dell'unità `/proc/<pid>/cwd` degli
  altri processi è negato. Fino al 2026-11-10 il controllo stava quindi
  prima del giro, fuori dal namespace; oggi è a valle e
  legge i transcript, che dal recinto sono leggibili (sezione «Sessioni
  concorrenti»);
- **permessi**: con `--setting-sources project` il `.claude/settings.json`
  del repo si fonde con il file del ciclo. I deny valgono anche contro un
  allow del ciclo; gli allow valgono se il workspace è fidato
  (`hasTrustDialogAccepted`, che non passa alle sottocartelle), altrimenti
  Claude li ignora con un avviso. Con `--setting-sources ""` il file del
  ciclo resta l'unico, ma il giro perde `CLAUDE.md` e le skill del
  progetto: non è usabile.

Regola che ne segue: gli allow del `.claude/settings.json` di un repo con
ciclo autonomo stanno dentro quelli dei permessi del giro (`o3/ciclo/permessi.json`, o
`.claude/ciclo.json` nei repo non ancora migrati); i deny vi si possono
aggiungere liberamente. In salute oggi `settings.json` porta solo deny.

## Grafie dei permessi

`o3/scripts/sonda-grafie.sh` lancia `claude -p` con il `settings.json` fuso
del giro (`.git/lanciatore/`) e le sue opzioni di permesso (`--setting-sources project`,
`--permission-mode dontAsk`), una prova per forma di comando. Ogni forma è
innocua ed è composta solo da comandi in allow: un diniego dipende quindi
dalla grafia, non dal contenuto. Una prova di controllo in deny (`find`)
deve uscire negata. Si lancia in sessione col custode quando il ramo `ia`
porta una nuova versione di Claude Code. Il giro non la lancia, perché
`claude -p` lì è negato. Gli esiti si accumulano in
`i1/grafie-permessi.jsonl`, una tornata per versione, circa 0,11 USD a
prova.

Tornata del 2026-10-28, Claude Code 2.1.311:

- **negate**: graffe `ls {o1,o2}`, `cd o1 && ls`, la sostituzione
  `$(…)`, il ciclo `for`, e un heredoc seguito da `&&`
  (`git commit -F - <<'EOF' && git log -1`);
- **concesse**: `&&` e `;` fra comandi in allow, pipe, redirezioni
  (`2>/dev/null`), `cd` da solo, l'heredoc da solo (`cat`,
  `git commit -F -`, `-m "$(cat <<'EOF' …)"`), `-m` ripetuti, e graffe e
  pipe dentro le virgolette (`jq -n '{a: 1, b: 2}'`, `--jq`).

Le cause dei dinieghi dei giri sono quindi verificate:

- il commit negato del 2026-10-27 non cadeva per l'heredoc ma per
  l'heredoc unito a `&&`;
- `cd` cade quando apre un composto, non da solo, e questo spiega anche il
  diniego del 2026-10-24 (`…; cd /home/stele/nixos && jq …`);
- le graffe contano solo fuori dalle virgolette.
- il `git log` negato del 2026-11-02 aveva `%(trailers:…)` fuori dalle
  virgolette, cioè bash non valido: la sonda su 2.1.312 nega la forma nuda
  e concede quella fra apici, già coperta da `Bash(git log*)`.

Il `gh issue view … --jq '{state,updatedAt,n:(.comments|length)}'`, negato
il 2026-10-27 su 2.1.308, passa identico su 2.1.311. Su quella versione non
è più riproducibile, e la causa resta legata alla versione precedente.

La regola delle grafie della skill `cycle` (uno per chiamata, niente `;`,
`&&`, `for`, graffe, heredoc) è più stretta del necessario su `;`, `&&` e
heredoc da soli, ma resta corretta: evita tutti i casi negati.
Allargarla spetta al canone di `method`.

## Da verificare

- rimontaggio del Drive durante un giro, e col lanciatore un namespace
  dell'agente che fallisce (`226` sull'unità transitoria): come lo chiude
  il lanciatore non è ancora visto in un fallimento reale.

Connessioni:

- [home-manager](home-manager.md)
- [rclone-gdrive](rclone-gdrive.md)
- [secrets-management](secrets-management.md)
