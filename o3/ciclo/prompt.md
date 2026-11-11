# Ciclo autonomo di nixos

Esegui `/cycle autonomo`: un giro `eval all → exec all → commit` senza
custode, secondo la skill `cycle` del repository. Qui sta solo ciò che è
locale.

Fin dalla prima chiamata, prima ancora di aver caricato la skill: un comando
per chiamata Bash, senza `cd` né composizioni. I giri del 2026-11-06 e del
2026-11-08 hanno aperto con lo stesso comando composto, negato.

## Copertura

Sei al gradino 1: il timer lancia l'unità `ciclo-nixos` su `deck` ogni
giorno alle 04:30, mentre il custode dorme e prima di `method`; il giro è
coperto da `ciclo-autonomo`. Un avvio a mano dell'unità resta coperto dallo
stesso criterio. Il perimetro è quello del criterio `ciclo-autonomo` di
`autonomy.md`, regola di sospensione compresa; i permessi sono quelli di
`o3/ciclo/permessi.json`, accanto a questo prompt.

Trailer di copertura nel commit del giro, in una di due forme secondo come
è partito il giro:

```
Impatto-motivo: ciclo-autonomo (autonomy.md, ciclo schedulato)
Impatto-motivo: ciclo-autonomo (autonomy.md, avvio a mano)
```

Lo distingue l'orario della riga `partenza` del tuo tentativo in
`i1/giri/tentativi.jsonl`: una partenza nel minuto delle 04:30 è il timer,
ogni altro orario un avvio a mano. Se non riesci a distinguerli usa «ciclo
schedulato» e dichiaralo nel resoconto.

## Task

Il giro pianifica i task ma non li esegue (`autonomy.md`, `ciclo-autonomo`):
una notizia nuova, passata per lettura `i2/` e verdetto `i3/`, ne corregge
specifica, priorità, dipendenze e attese, o crea e cancella task. I passi di
un task `o2/` restano alla sessione col custode; gli atti del giro sono
quelli ricorrenti di `/manutenzione`, sotto.

## I sei stadi, non solo /manutenzione

`/manutenzione` è il centro degli atti del giro, non il giro: la sua diagnosi
sta in `perceive`, i suoi atti in `perform` (skill `cycle`, «Stadi»). Invoca `eval all` ed
`exec all` col tool Skill; il minimo di ogni stadio è in fondo alla sua
sezione delle skill. Dal 2026-11-05 al 2026-11-07 i giri si erano ridotti a
`/manutenzione` più un ritocco al task in testa
(`i1/ciclo-stadi-saltati-20261107.md`). Al minimo canonico di `perceive`
questo repo aggiunge i gesti del dominio:

- la fase diagnosi di `/manutenzione`, con derive di sistema e home e rami
  dovuti;
- `systemctl --user --failed` e `systemctl --failed`;
- `python3 o3/tools/kb_tools.py fidelity`.

## Tendenze del giro

Le tendenze del passo 3c di `exec plan` si leggono con
`tail -n 28 i1/giri/tentativi.jsonl` (costi, durate, dinieghi delle ultime
due settimane). Senza questa lettura il resoconto non scrive «nessun
rilievo».

## Fatti e fonti nel resoconto

Un fatto esterno non riletto nel giro porta la data della sua fonte
(«#9289 aperta al 2026-10-27»), o si rilegge: `gh issue view` è concesso.
L'assenza di un segnale nomina il canale («nessuna ricorrenza segnalata dal
custode»). Il giro non conosce il proprio costo: lo registra la chiusura, il
resoconto non lo stima.

## /manutenzione al centro

Nel giro esegui `/manutenzione` secondo la sua skill, in due fasi, col suo
lock in `i1/manutenzione.json`. In `perceive` la fase diagnosi, in sola
lettura. In `perform`, dopo `compare` e `plan`, la fase atti: i rami `ia` e
`home-manager` eseguono da soli bump e switch su `deck`, `nix flake update
ai` o `nix flake update home-manager`, poi un solo
`o3/scripts/con-identita.sh home-manager switch --flake .#stele@deck` per tutti, scritto così, senza
sostituzioni di comando. Un verdetto o un piano che ferma un ramo si rispetta
(skill, «Due fasi»). `casa` e `world` restano diagnosi. Il bump di un pacchetto overlay home-level segue la skill; uno
system-level si ferma alla proposta. I commit che la skill farebbe da sola
confluiscono nell'unico commit del giro.

Se lo switch di `deck` fallisce nella build, prima di attivare, e del bump è
cambiato solo `flake.lock`, un guasto upstream non deve fermare il giro
seguente col tree sporco (2026-11-09, codex 0.167.0). Ripristina il lock con
`o3/scripts/ripristina-lock.sh`, controlla con `o3/scripts/home-drift.sh` che
il verdetto sia `allineato`, non registrare i rami del bump, che restano
dovuti, e chiudi col commit del resto del giro, verifiche comprese. Il guasto
va nel corpo del commit e in `Attenzione:`.

In ogni altro caso, uno switch fallito dopo l'attivazione, un bump che ha
toccato anche altri file o un verdetto diverso da `allineato`, niente commit:
il working tree resta com'è e lo dichiari nel resoconto.

## Gli altri host

Il giro non agisce su altri host. `game` e `neve` alle 04:30 sono spenti:
li cura il custode, con `/manutenzione` lanciata da loro o con `remoto` in
sessione quando li accende. La loro assenza da `applicato_su` non è
un'incertezza del giro e non va nel resoconto. `norvegia` e `svezia`
girano dal repo `example-org/nixos-ufficio` dal 2026-11-04: questo giro non li
legge né li tocca.

## Host e verifiche

L'host è `deck`, il checkout servito: il commit ripubblica le viste di
`nixos` in LAN. Le verifiche sono quelle del gate di
`/commit`, `python3 method/../o3/commit_gate.py prima` (profilo in
`o3/commit_gate.toml`), più una propria del giro: `o3/tools/check.sh --flake`,
una volta prima del commit, che valuta tutte le configurazioni in circa un
minuto, senza compilare.

## Autovalutazione del giro

L'autovalutazione ha le due parti della skill `cycle`, gli **stadi** e la
**procedura**; la procedura comprende quella che chiede `/manutenzione`.
Gli stadi si elencano tutti e sei, col minimo eseguito e ciò che manca: la
descrizione degli esiti non la sostituisce. Le decisioni prese entro la
delega, come un rischio assegnato o una voce non promossa, hanno una voce
propria col motivo.
Le attenzioni hanno memoria secondo la stessa skill. La proposta che tocca
file fuori dal tuo perimetro (la skill, questo prompt, `remoto`,
`autonomy.md`) resta proposta, in un task `o2/` col campo `decidere:` nel
frontmatter.

## Atti sul Mondo

Restano delegati il bump di `ia` e `home-manager`, lo switch home-level su
`deck` e il push. Restano
proposte: `sudo`, `nixos-rebuild`, reboot, ogni modifica a
`o3/modules/system/`, `o3/hosts/` e `o3/identity/`, al modulo e al registro
dei cicli autonomi, allo strumento `remoto`, ad `autonomy.md`, `CLAUDE.md`,
`goal.md`, `.claude/` e `o3/ciclo/`, e ogni altro atto su host diversi da `deck`.
