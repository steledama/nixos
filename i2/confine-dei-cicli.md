---
ciclo: runtime
---

# Confine dei cicli su deck

Lettura del confine di esecuzione dei giri autonomi su `deck` nella forma
del contratto canonico «Delega e confine di esecuzione»
([consent](../method/consent.md), method `15f4d3f`). Il caso esaminato è
`ciclo-salute`, su richiesta della sessione salute inoltrata dal custode il
2026-11-20; il meccanismo è lo stesso per tutti i cicli di `deck`, e la
parte generale vale anche per il task parallelo di method
(`o2/confine-del-giro.md`). Sulla base di queste prove il custode ha
ritirato lo stesso giorno i cicli autonomi di salute (salute `0ce53a5`),
economia e method: il confine che richiedevano costava troppo per una
postazione di casa, dove privacy e minimalismo vengono prima. Poi anche quello
di `nixos`: a casa nessun ciclo gira senza custode. Le prove restano la
misura del meccanismo, se un giro senza custode tornasse in discussione.

Fonte: `o3/tools/prova-confine.sh salute`, eseguito su `deck` il
2026-11-20 alle 16:24 CET, in sessione col custode, col recinto della sonda
generata (`ciclo-salute.json` del profilo home attivo) più tre maschere
fittizie. Verdetto: **il recinto tiene il filesystem diretto, non le
capacità**. Un giro con esecuzione di codice raggiunge, con la stessa
identità, servizi che stanno fuori dal namespace.

## Meccanismo

- Unità transitoria utente `ciclo-<repo>-agente` (nodo `cicli`,
  tolto con il meccanismo): mount namespace con home in sola lettura, scrivibili checkout,
  stato, `~/.claude`, `~/.claude.json`, `~/.codex` e i path del repo;
  `InaccessiblePaths` per i mount privati; `NoNewPrivileges`,
  `RuntimeMaxSec`, `BindsTo` verso l'unità esterna.
- Stessa identità dell'utente operativo; nessun filtro su rete, socket di
  sessione, D-Bus o processi.
- Wrapper `gog --gmail-no-send` in testa al `PATH`.
- I permessi dell'harness (`salute/o3/ciclo/permessi.json`) dichiarano la
  delega ma non la limitano: il giro può modificare `o3/**` e `tests/**` e
  lanciare `python3 o3/health_data.py *` e `python3 -m unittest *`, quindi
  eseguire codice arbitrario. Il confine effettivo è quello del sistema.

## Che cosa regge

Prove dirette dall'interno del recinto:

- home in sola lettura; `o3/ciclo` e `.git/hooks` del checkout in sola
  lettura;
- Drive del custode in sola lettura fuori da `salute/`, scrivibile in
  `salute/`;
- Drive di familiare e la sua configurazione rclone illeggibili;
- casella `pressione-salute` leggibile, non scrivibile;
- maschere fittizie: `ReadOnlyPaths` e `InaccessiblePaths` tengono per
  l'accesso diretto;
- `environ` degli altri processi dell'utente illeggibile.

## Che cosa esce

Prove indirette, tutte riuscite:

- **manager utente**: `systemd-run --user` dal recinto avvia un'unità fuori
  dal namespace che legge il file mascherato, scrive quello in sola lettura
  e resta attiva dopo l'arresto del recinto. `ciclo-recinto-ferma` verifica
  il solo cgroup dell'agente;
- **niri**: `niri msg action spawn` lancia un processo fuori dal recinto
  che legge il file mascherato;
- **Herdr**: il socket risponde ed elenca i pannelli aperti, fra cui le
  sessioni del custode e il pannello `ssh norvegia`. L'invio di testo
  (`herdr agent prompt`, `herdr pane send`) non è stato provato: segue dalla
  CLI;
- **Secret Service**: raggiungibile, keyring `login` sbloccato con 5 voci.
  Un client del bus può leggerle tutte, non solo il token di `gog`;
  nessuna voce è stata letta;
- **SSH**: `~/.ssh/id_ed25519` senza passphrase leggibile, `ssh-agent` con
  una chiave caricata. Nessuna connessione è stata tentata;
- **rete**: uscita libera (DNS, TCP 443 e 22 verso GitHub);
- **credenziali in chiaro**: `rclone.conf` leggibile e scrivibile, remote
  del custode con scope `drive` intero e nessuna `root_folder_id`: via
  API raggiunge tutto il Drive del custode, in scrittura, oltre la
  sottocartella che il mount limita. Leggibili anche `~/.config/gh`,
  `~/.config/gogcli`, `~/.local/share/keyrings` e
  `~/.config/nixos/identity`;
- **persistenza**: scrivibili `~/.claude/skills`, `~/.codex/config.toml` e
  `.claude/` del checkout; una scrittura lì entra nelle sessioni e nei giri
  successivi, anche di altri repo;
- **maschere con `-`**: un path assente all'avvio e creato dopo resta
  accessibile. È la forma generale del riscontro sui `.env.*` del
  2026-11-18 e vale per i `privatePaths` assenti all'avvio;
- **dati degli altri repo**: la home in sola lettura resta leggibile, quindi
  ogni giro legge i checkout degli altri. Il ritiro del ciclo di salute non
  toglie i suoi dati sanitari né `~/salute/.env` (credenziali Zepp) dalla
  portata del giro di `nixos`, che ha la home scrivibile: nessun ciclo li
  dichiara inaccessibili.

## Ciclo method

`o3/tools/prova-confine.sh method`, 2026-11-20 alle 18:14 CET: stessi esiti
del caso salute per manager utente, socket, Secret Service, SSH, rete,
persistenza e maschere con `-`. Il registro di method non dichiara path
propri: `rclone.conf` è leggibile ma non scrivibile, e il Drive solo in
lettura. Leggibile un `.env` di un altro checkout, quello di salute.

## Non verificati

- invio Gmail col token di `gog`: lo scope non è stato letto,
  lo ferma solo il wrapper;
- host che accettano la chiave SSH;
- invio di testo in un pannello Herdr;
- lettura effettiva di una voce del Secret Service;
- filtro di rete per un'unità del manager utente (`IPAddressDeny` richiede
  BPF, non provato);
- motore Codex: `--recinto-host` usa la stessa unità, ma la prova non è
  stata fatta con Codex;
- arresto dei processi lanciati via niri o in unità esterne: non legati ad
  alcuna unità del ciclo.

## Riesame

Meccanismo e strumento di prova (`o3/tools/prova-confine.sh`) sono stati
tolti e restano in git. Se un giro senza custode tornasse in discussione,
le prove si rifanno sul meccanismo nuovo prima di dichiararne il confine.
Le alternative valutate (canali chiusi con la
stessa identità, identità dedicata per ciclo, checkout non usati resi
inaccessibili) sono nella storia git; il custode ha scelto di non avere
giri senza custode.
