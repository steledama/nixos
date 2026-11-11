# Contesto e controlli comuni

Esegui `hostname` per sapere su quale dei tre host gira la sessione
(`deck`, `game`, `neve`): `system-versions.sh` confronta solo l'host
corrente.
Poi `git pull --ff-only` a working tree pulito (`CLAUDE.md` «Pull remoto»):
`i1/manutenzione.json` funziona da lock cross-host solo se leggi lo
stato più recente, non quello locale eventualmente indietro. Con modifiche
locali o branch divergente non fare merge né rebase: fermati e riferisci,
perché il lock letto sarebbe inaffidabile.

## Scadenze e allineamento

```bash
o3/scripts/maintenance-due.sh        # host corrente
o3/scripts/maintenance-due.sh deck   # prospetto per un altro host, sola lettura
```

Lo script è la fonte del lock: legge il registro e i task `w<n>` del plan,
mostra ogni voce con applicabilità all'host, data/ora, cadenza, giorni civili
trascorsi, stato, freschezza e presenza in `applicato_su`. Non esegue atti
né modifica il registro. Leggi il JSON per esito, provenienza e giudizio;
un file o una voce assenti valgono «mai controllato». Una cadenza assente
su una voce già datata è un errore da correggere, non un via libera.

- **Calendario:** `dovuto` da quando i giorni civili raggiungono la cadenza;
  prima è `non dovuto`. La freschezza numerica è `anticipato` sotto soglia,
  `in linea` alla soglia, `in ritardo` oltre: nel giudizio pesa quanto lo
  scarto sia significativo, non il solo nome. Una voce mai controllata va
  diagnosticata e dotata della sua cadenza nel registro.
- **Debounce:** meno di 10 minuti dal timestamp impediscono una nuova
  diagnosi/scrittura della voce, anche con scope forzato. Non blocca
  l'allineamento: questo modifica solo `applicato_su`, lasciando data/ora
  della diagnosi intatte.
- **Revisioni:** `pacchetti_host` segue il confronto di rev in
  [sistema](sistema.md).
  `dovuto su diagnosi/allineamento` è condizionale: valuta solo durante la
  diagnosi di gruppo su quell'host o prima del suo rebuild, mai come
  aggiornamento indipendente. `revisione assente` richiede prima la
  diagnosi di gruppo. Le voci host-specifiche restano intra-host.
- **Orfane:** `orfano.world.<titolo>` (`voce orfana`) è una voce `world`
  il cui task non ha più una riga `w` con `probe:` nel plan;
  `orfano.<percorso>.promosso` (`promosso orfano`) nomina un task uscito
  dal plan. È un dato vecchio, non un'attesa, e si corregge nello stesso
  run, anche se nessun ramo è dovuto. Cerca il commit che ha tolto la riga,
  con `git log -S '<titolo>' --format='%h %ad %s' --date=short -- o1/plan.md`.
  Poi togli la voce con `o3/scripts/registro.sh 'del(.world["<titolo>"])'`,
  oppure riporta il campo a `null` con `.<percorso> = null`, e nomina nel
  resoconto voce, commit e data. È una scrittura del registro, autonoma come
  il log. Se il task è ancora vivo con un titolo diverso, la voce non è
  orfana ma rinominata: spostala sotto il titolo nuovo e dillo nel resoconto.
- **Applicabilità:** le righe `no` danno contesto, non estendono lo scope.
  Da `deck` applica anche [gli altri host da deck](remoto.md); il prospetto di un
  altro host non autorizza comandi remoti.

**Allineamento, indipendente dal lock.** Per le voci dei rami che
portano `applicato_su`, verifica l'host anche se la diagnosi non è dovuta. La
verifica sta nella fase diagnosi, lo switch nella fase atti:

- `ia`, `home-manager`, `casa.gogcli`: se manca, applica il pin già noto
  con `o3/scripts/con-identita.sh home-manager switch --flake .#$USER@$(hostname)`, senza rifare
  diagnosi, changelog o bump. Aggiungi l'host solo dopo successo. Per
  `game` e `neve` da `deck` vale [remoto](remoto.md).
- `casa`: se manca, riporta «rebuild pendente», con la diagnosi
  di `host_controllato`. L'attivazione di sistema è del custode: fornisci
  il comando minimo, non proporre di eseguire tu `sudo` (prompt password
  interattivo). Aggiungi l'host quando il rebuild è eseguito e riscontrato.

Sul medesimo pin la lista si estende; un nuovo pin invalida la lista
precedente. La lista nuova certifica solo gli host con attivazione
riuscita, non la sola diagnosi. Senza esito di attivazione, resta vuota.

**Deriva di configurazione.** `applicato_su` segue il pin, non i moduli.
Anche con tutti i rami bloccati esegui entrambi i controlli locali; da
`deck` aggiungi quelli degli host raggiunti secondo [remoto](remoto.md):

```bash
o3/scripts/system-drift.sh
# da deck, revisione letta da remoto stato:
o3/scripts/system-drift.sh <host> <revisione> <sistema>
o3/scripts/home-drift.sh
# da deck, riga home: di remoto stato, copiata fra apici:
o3/scripts/home-drift.sh <host> '<riga home:>'
```

`system-drift.sh` riconduce la revisione attiva al commit e confronta il
toplevel attivo con `HEAD` valutato con l'identità locale e la stessa
revisione (righe `revisione:` e `sistema:` di `remoto stato` da deck).
Riporta `allineato`, `deriva` con commit candidati e comando minimo, oppure
`non misurabile` (build dirty/revisione sconosciuta), senza stimare dalla
data. Per il significato della misura home e il limite sul candidato
ancora da committare leggi `kb/home-manager.md`, «Verifica della home
attiva». Da `deck` misura anche `game` e `neve` accesi secondo
`remoto.md`. I due script non modificano il log né `applicato_su`.
