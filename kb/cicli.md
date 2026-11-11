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

- **`o3/cicli.nix`**, le decisioni: per ogni repo host, checkout, branch,
  cadenza e orario, tempo massimo, budget, stato (`manuale`, `timer`,
  `esterno`) e recinto. Un solo `host` per repo: un solo host tiene il
  ciclo autonomo di un repo per costruzione. I cicli di `bi` e `baserow` su
  `svezia` e `danea-auto` (Task Scheduler) li dichiara il repo
  `example-org/nixos-ufficio`.
- **`o3/modules/home/cicli.nix`**, il meccanismo: importato da tutti i
  profili in `o3/home/default.nix`, genera `ciclo-<repo>.service` solo dove
  `host` coincide con l'`hostname` del profilo, e il `.timer` solo in stato
  `timer`. Pubblica anche il quadro completo in
  `~/.local/state/ciclo/decisioni.json`.

Confine: `nixos` decide dove e quando, il repo decide cosa. Il prompt del giro
e i permessi del solo ciclo autonomo (passati con `--settings` e
`--setting-sources project`) sono file del repo, parametrizzabili per repo
(`prompt`, `settings`). Il lettore condiviso
`o3/modules/home/ciclo/registry.nix` applica a cicli e presentazioni i default
`o3/ciclo/prompt.md`, `o3/ciclo/permessi.json` e `i1/giri`; il registro
`o3/cicli.nix` dichiara soltanto le eccezioni. Le voci `esterno`, prive di
checkout, restano fuori dai default NixOS.

Il lettore aggiunge `<checkout>/o3/ciclo` ai `readOnlyPaths`, senza
duplicati e anche con `homeWritable`: il giro non modifica le proprie
istruzioni. Un repo può sovrascrivere prompt e settings e dichiarare
ulteriori percorsi protetti; `giri = null` conserva le tracce nello stato
utente. `decisioni.json` pubblica le decisioni esplicite del registro,
mentre i JSON delle unità contengono i valori effettivi con i default.
I nuovi adottanti devono avere i file e la cartella giri ignorata da Git
prima di attivare il ciclo, altrimenti l'avvio si ferma con codice `14`.

Ciò che vale per tutte le sessioni lo passa l'unità, perché `--setting-sources
project` salta `~/.claude/settings.json`: le variabili d'ambiente in
`Environment`, e le impostazioni host-wide in `hostSettings` del modulo
(oggi `attribution` vuoto, decisione del custode del 2026-10-11, method
`e5a57bb`). `ciclo-avvio` le fonde sopra i permessi del repo (`settings`, vince
l'unità) in `~/.local/state/ciclo/<repo>/settings.json`, che è il file
passato a `--settings`; la sonda fa la stessa fusione e ne registra
`attribution`. Verificato su claude 2.1.295 in `-p`: senza la fusione il
commit porta il trailer `Co-Authored-By`, con la fusione no.

Unità utente, non di sistema: il lingering è attivo su `deck`,
lo switch è home-level, e l'unità trova nella home le credenziali di Claude
(`~/.claude/.credentials.json`) e la chiave ssh senza passphrase, usata con
`BatchMode` e senza agent. Claude è il pacchetto di `pkgs-ai` fissato nel
modulo, non quello del profilo.

## Recinto

L'unità è il recinto vero: la home è in sola lettura e restano scrivibili il
checkout, la cartella di stato, `~/.claude` e `~/.claude.json` e i path che il
repo dichiara; i path inaccessibili si dichiarano per repo. `Type=exec` con
`RuntimeMaxSec` (su `oneshot` non ha effetto), `NoNewPrivileges`, stdin nullo,
`GIT_TERMINAL_PROMPT=0`, `GIT_SSH_COMMAND="ssh -o BatchMode=yes"`.

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

`ciclo-avvio` controlla prima di Claude, senza mai merge, rebase o stash.
Ogni arresto lascia unità fallita, motivo e codice di uscita:

- `75` un altro ciclo tiene il lock (`flock` nella cartella di stato);
- `11` branch diverso da quello dichiarato, o senza upstream;
- `10` working tree sporco;
- `13` fetch o `pull --ff-only` falliti, o un pull che cambierebbe un
  `readOnlyPaths` del checkout (`pull-in-sola-lettura`: fallirebbe a metà sul
  recinto e lascerebbe il tree sporco; il pull va fatto fuori dall'unità);
- `12` branch divergente da `origin`; solo avanti si procede (il push lo fa il
  giro), solo indietro si fa `pull --ff-only`;
- `14` prompt o permessi del ciclo mancanti nel repo, o cartella `giri` non
  ignorata da git;
- `15` un'altra sessione ha lavorato nel checkout durante il giro, e
  `ciclo-concorrenti` ne ha bloccato il commit (`sessione-concorrente`, vedi
  sotto);
- `20` Claude esce con codice non zero, `21` Claude riporta `is_error`;
- `16`, solo nella sonda: il recinto reale differisce da quello dichiarato.

- `226` systemd non riesce a preparare il namespace, prima di
  `ciclo-avvio`: per esempio un path di `readWritePaths` su un mount Drive
  che risponde I/O error perché `deck` non risolve i nomi (2026-10-14,
  `i1/ciclo-salute-namespace-20261014.md`). Anche `ciclo-chiusura` fallisce
  nello stesso namespace, quindi la chiusura la scrive `ciclo-namespace`,
  primo `ExecStopPost` con `+`, fuori dal recinto: agisce solo su `226`,
  registra `esito: errore`, `motivo: namespace` senza riga di partenza, e
  non legge nulla che il giro possa scrivere (niente git nel checkout,
  dove un hook o `core.fsmonitor` del giro girerebbe senza recinto).

L'unità non committa né spinge: lo decide il giro del repo.

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

In `~/.local/state/ciclo/<repo>/`, leggibile dalla home dello stesso host,
oppure nella cartella del checkout che la voce dichiara come `giri` (canone
`i1/giri`, ignorata da git; method per primo, il 2026-10-19). Lì il giro può
riscriverli: il custode ha accettato che le tracce stiano nel perimetro del
giro. `ciclo-avvio` sceglie la cartella dopo il pull d'avvio, con `git
check-ignore`: gli arresti precedenti (lock, branch, tree, fetch e pull) e
quelli di `ciclo-namespace`, che gira fuori dal recinto e non scrive mai nel
checkout, restano nello stato; il primo
tentativo che passa il controllo li sposta nella cartella in ordine
cronologico, prima della propria partenza, e la prima volta porta con sé lo
storico. Lock, `corrente.json`, `sonde.jsonl` e il `settings.json` fuso
restano sempre nello stato.

- `tentativi.jsonl`: due righe per tentativo con l'id di systemd
  (`INVOCATION_ID`, lo stesso del journal). `partenza` la scrive l'avvio;
  `chiusura` la scrive `ciclo-chiusura` da `ExecStopPost`, che gira anche
  dopo timeout e kill (dopo un fallimento del namespace la sostituisce `ciclo-namespace`): esito (`riuscito`, `arresto`, `errore`, `timeout`),
  motivo, risultato e codice di systemd, `HEAD` prima e dopo, commit, push
  (`HEAD` uguale a `@{u}`), `oggetto` (prima riga del commit del giro, `null`
  se `HEAD` non si è mosso), tree sporco dopo, `is_error`, numero di
  `permission_denials` e `dinieghi` (lista di `{tool, input}`, input =
  comando, file o URL troncato a 1000 caratteri), costo, turni e durata:
  quanto basta a leggere il giro senza aprire i trascritti chiusi;
- `giri/<id>.jsonl`: lo stream di Claude (`--output-format stream-json
--verbose`), un evento per riga, ogni comando del giro compreso: rende
  leggibile dopo un aggiramento del recinto. Gli ultimi 60, mai pubblicati;
  la chiusura ricava `is_error`, negazioni, costo e durata dall'evento finale
  `result`, assente se il giro è interrotto;
- `ultimo.json`: l'ultima chiusura.

Forma minima: il contratto definitivo con la home si concorda in method.

`SERVICE_RESULT=success` da solo non prova che il giro sia riuscito:
con `Type=exec` anche uno stop manuale con SIGTERM può produrlo. La
chiusura richiede inoltre uscita normale dell'avvio con codice 0,
`claude_exit: 0` e un evento `result` con `is_error: false`. Un risultato
systemd `success` senza queste conferme diventa `arresto`, motivo
`interrotto`; timeout ed eventuali motivi espliciti conservano il loro esito.

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
(`lanciatore = true` nel registro) non usano più `ciclo-avvio`. Per `nixos`
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
registro non tiene per questi cicli né `maxRuntime` né `agentMaxRuntime`
né `maxBudgetUsd`, e `registry.nix` fallisce la valutazione se li trova. Il task è `o2/lanciatore-ciclo-nel-metodo.md` di method, passo 2.

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
paracadute fisico, uguale per tutti i cicli col lanciatore
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

Sequenza di switch su `deck`, al custode:

1. `git -C ~/method pull --ff-only`: un lanciatore precedente a `477b442` esce
   con `2` su `--recinto-ferma` prima di scrivere qualunque traccia;
2. `o3/scripts/con-identita.sh home-manager switch --flake .#stele@deck` da `~/nixos`, aggiornato;
3. `systemctl --user start ciclo-method-sonda` e lettura di `sonde.jsonl`;
4. un giro a mano, `systemctl --user start ciclo-method`, col Claude vero.

Collaudo del 2026-11-08 su `deck`, con la sequenza qui sopra: sonda superata e
giro a mano riuscito col lanciatore (`87eac6f5`, commit e push, 2,55 USD, nessun
`fermo`), senza che `ciclo-method-agente` restasse in vita. Il tetto di tempo è
provato solo su unità transitorie.

Il recinto aggiunge in sola lettura ciò che git esegue dal lanciatore fuori
dal recinto: `o3/lanciatore.py` e, da method `de73101`,
`o3/esecutore_codex.py` del canone, `.git/config`, `.git/hooks` e
`.git/lanciatore` del checkout (criterio di method `477b442`). Il lanciatore
dev'essere almeno a `477b442`, che introduce `--recinto-ferma`.

La sonda `ciclo-method-sonda` è `lanciatore.py --controlli`, fuori da ogni
namespace come il lanciatore, più `ciclo-recinto` in un'unità transitoria
`ciclo-method-sonda-recinto` col recinto dell'agente. Una sessione aperta
(`15`) con un recinto sano salta la sonda con codice `0`, come faceva
l'`ExecCondition`. La riduzione della sonda è una proposta della sessione di
casa: la decide il custode.

Collaudo di `salute` ed `economia` del 2026-11-11 su `deck`: sonde superate,
poi un giro a mano di ciascuno, avviati insieme alle 17:19:55. Entrambi
riusciti (1,36 e 1,16 USD), stop verificato (`stato_finale_verificato`),
nessun `fermo`. Il pull del canone è fallito in tutti e due: i due
lanciatori hanno tirato `~/method` nello stesso istante, mentre un pull
singolo nello stesso contesto riesce. I timer non si sovrappongono. In
`economia` il giro ha trovato le modifiche di una sessione del custode,
non ha committato e l'ha scritto nell'avviso. La chiusura però riporta
`commit: true` con l'oggetto del commit del custode (`5622e30`): il
lanciatore legge il cambio di `HEAD`, non chi ha committato.

### Quota e fallback

Da method `fce8afe` la chiusura porta `engine`, `engine_attempts` con
l'osservazione del provider di ogni tentativo e `costo_usd` cumulato: un
rifiuto per quota esaurita resta leggibile in `i1/giri/tentativi.jsonl` di
ogni ciclo col lanciatore. Il percorso legacy non riceve questa
osservazione.

Da method `201a6eb` il motore lo sceglie il repo, con `motori` nel proprio
profilo (per esempio `["claude", "codex"]`, anche al contrario). Il secondo
subentra una volta sola, se il primo è indisponibile prima di qualunque
atto. Codex passa dall'esecutore canonico `o3/esecutore_codex.py` di
method, che traduce `permessi.json` e l'hook sul commit; senza tetto in USD
la chiusura dichiara `budget_usd_imposto: false`. La parte dell'host su
`deck`, dal 2026-11-11: lo script `lancia` passa `--codex` col binario di
`pkgs-ai`, e il recinto dei cicli col lanciatore ha `~/.codex` scrivibile
(sessioni, rinnovo di `auth.json`). Interprete Python nello store e rete
sono già raggiungibili. Provato: `codex login status` riesce in un
recinto equivalente, e il giro a mano di method del 2026-11-11 alle 18:17,
con Codex primo, è riuscito dall'unità `ciclo-method` (commit `3b618dc`,
push in rete, nessun diniego). Il secondo motore si accende repo per repo nel suo
profilo, dopo un primo giro a mano col custode.

## Sessioni concorrenti

Le sessioni aperte non si controllano prima del giro ma al commit (custode,
2026-11-10): una sessione Claude o Codex lasciata aperta e inattiva nel
checkout è innocua e non deve fermare il ciclo; conta solo una che lavora
mentre il giro gira, perché il commit del giro potrebbe portarsi dietro le
sue modifiche. Prima il controllo stava in `ciclo-sessioni`, prima del lock:
un processo Claude con la cwd nel checkout, o un rollout Codex scritto negli
ultimi 60 minuti, fermavano il giro (economia, 2026-11-10 alle 14:00: una
sessione Codex ferma dalle 13:34 ha fatto saltare il giro).

`ciclo-avvio` tocca il marker `inizio-giro` nella cartella di stato subito
prima di lanciare Claude. `ciclo-concorrenti` è un hook `PreToolUse` su
`Bash` negli `hostSettings` di ogni giro: davanti a un `git commit` cerca i
transcript aggiornati dopo il marker, cioè

- `~/.claude/projects/<checkout codificato>/*.jsonl` (ogni carattere non
  alfanumerico del path diventa `-`; il giro gira con
  `--no-session-persistence` e non ne lascia di suoi);
- `~/.codex/sessions/**/rollout-*.jsonl` con la cwd della `session_meta` nel
  checkout (le sessioni Codex sono thread del daemon `app-server`, la cui
  cwd è dove è nato: `/proc` non le vede).

Se ne trova, blocca il commit con codice 2 e dice al giro di non riprovare,
lasciare il tree com'è e dichiararlo in `Attenzione:`; scrive
`concorrenti.json`, che `ciclo-avvio` legge dopo Claude per fermarsi con `15
sessione-concorrente`. La riga di chiusura porta `sessioni_concorrenti`, il
tree resta sporco e il giro successivo si ferma su `10` finché il custode
non riconcilia. Una sessione che scrive solo dopo il commit del giro trova
il commit già fatto, come dopo un pull. I cicli col lanciatore canonico
(method) non hanno il marker e l'hook non fa nulla: lì le sessioni le
controlla `lanciatore.py`.

Il timestamp di modifica è solo un prefiltro. Come nel lanciatore canonico
(method `18a9f5a`), si leggono gli ultimi 4 MiB dal fondo fino al primo evento
con timestamp non successivo al marker. Conta solo una chiamata a uno
strumento: per Claude un evento `assistant` con `tool_use` in
`message.content`; per Codex un `response_item` con `payload.type` che
finisce in `_call`. Testo, output degli strumenti ed eventi senza timestamp
valido non contano.

La sessione che avvia il giro può quindi scrivere la risposta dopo il
marker senza bloccarlo. Una successiva chiamata a uno strumento conta ancora,
anche per leggere `journalctl` o `systemctl status`: controllare il giro da
un terminale esterno. L'avvio differito resta disponibile come margine
operativo, ma non serve per la sola risposta testuale:

```bash
systemd-run --user --on-active=120s --collect systemctl --user start ciclo-economia
```

## Sonda

`ciclo-<repo>-sonda` è la stessa unità, recinto compreso, in modalità sonda
(`CICLO_SONDA=1`): gli stessi controlli di sola lettura (lock, branch,
tree, prompt e permessi), niente fetch né pull, mai Claude.
Poi prova il recinto con `test -r`/`test -w`, senza scrivere: home e
`readOnlyPaths` in sola lettura, checkout, stato e `readWritePaths`
scrivibili, `inaccessiblePaths` illeggibili. Esito in `sonde.jsonl`, separato
dai tentativi.

## Uso

```bash
systemctl --user start ciclo-salute-sonda   # controlli e recinto, senza Claude
systemctl --user start ciclo-salute         # avvio a mano, fuori cadenza
systemctl --user list-timers 'ciclo-*'      # prossima partenza
journalctl --user -fu ciclo-salute
jq . ~/.local/state/ciclo/salute/ultimo.json
```

Salute è al gradino 1 dal 2026-10-11: timer ogni giorno alle 09:00 dal
2026-10-24 (alle 08:30 dal 2026-10-20, prima alle 12:00), quando di solito
sono arrivati la notte e lo yoga o la meditazione del primo mattino; l'invio
manuale dal lavoro entra nel giro del giorno dopo (custode, salute `48497e8`).
La mezz'ora in più dà tempo alla sincronizzazione automatica dell'orologio su
Android, che arriva tardi (custode, salute `1e599e7`). Il timer ha `Persistent=false`. Se `deck` è spento all'orario,
il giro non recupera all'avvio e dopo un'ora la home lo segna rosso come
partenza mancata, ed è vero. Se `deck` è sospeso, systemd fa partire il timer
scaduto alla ripresa (con `Persistent` o senza), e quella partenza tardiva
spegne il rosso. Una sessione Claude o Codex aperta in `~/salute` non ferma
il giro; ne blocca il commit solo se lavora mentre il giro gira (codice 15).

Nixos e method sono al gradino 1 dal 2026-10-17, su `deck`: timer ogni
giorno alle 04:30 e alle 15:00. Method gira dopo nixos, salute (09:00) ed
economia (14:00), perché il suo perceive trovi i giri degli adottanti del
giorno. Economia è passata dalle 13:00 alle 14:00 il 2026-10-21, su scelta
del custode: alle 13:00 il giro si era fermato per la sessione aperta del
custode in `~/economia`, e con il tetto di 45 minuti chiude prima di method.
Nixos è passato dalle 14:00 alle 04:30 il 2026-10-18, su scelta del
custode: il resoconto è pronto al risveglio, `deck` resta acceso di notte e
il giro finisce entro le 05:15 anche al tetto. Il
custode ha acceso il timer di nixos senza attendere un giro con bump e
switch veri; quella parte del perimetro si è collaudata al giro schedulato
del 2026-10-18 (bump di `ai`, `home-manager` e `gogcli`, switch su `deck`
riuscito, unità del giro non riavviata dallo switch). Prompt e criterio `ciclo-autonomo` passano al gradino 1 con il
timer, perché il giro si firmi col gradino giusto (regola nata dal primo giro
schedulato di economia).

## Esiti del gradino 0 e delle sonde

Su `deck`, 2026-10-11, salute:

- **giro riuscito** (commit `2eb8a69` in salute, push via ssh senza agent,
  1,85 USD, 4,5 minuti): `/eval`, `/exec` e `/commit` invocate davvero da
  `claude -p`, keyring di `gog` leggibile;
- **recinto sui mount FUSE**: la sonda trova `gdrive-personale` in sola lettura
  e `gdrive-personale/salute` scrivibile;
- **controllo `15`**: dentro il namespace dell'unità `/proc/<pid>/cwd` degli
  altri processi è negato. Fino al 2026-11-10 il controllo stava quindi
  prima del giro, in `ciclo-sessioni` fuori dal namespace; oggi è a valle e
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
del giro e le stesse opzioni dell'avvio (`--setting-sources project`,
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

- il blocco per sessione concorrente dentro un giro vero: il giro di
  economia del 2026-11-10 alle 15:21 ha committato e pubblicato `4083c8a`
  senza concorrenza (segnalazione della sessione economia); non prova il
  ramo di blocco;
- il ciclo di `method` col lanciatore alla prima partenza dal timer
  (2026-11-09 alle 15:00);
- rimontaggio del Drive durante un giro (con il Drive irraggiungibile
  all'avvio, l'unità non parte: cfr. «Avvio e arresti»);
- la chiusura di `ciclo-namespace` nella home: per il codice di
  `o3/view/ciclo.py` di salute, una chiusura senza partenza è un tentativo
  rosso col motivo `namespace`; derivato dal codice, non ancora visto in un
  fallimento reale (provato su un'unità transitoria il 2026-10-15);

Connessioni:

- [home-manager](home-manager.md)
- [rclone-gdrive](rclone-gdrive.md)
- [secrets-management](secrets-management.md)
