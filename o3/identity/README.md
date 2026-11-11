# Identità locale e template pubblici

Il repository pubblico contiene struttura e template. I dati reali sono in
`~/.config/nixos/identity/`, fuori da Git e dal checkout, e vengono passati
al flake come input esplicito. Non serve un secondo repository operativo.

## File

- `default.nix` qui importa `home.example.nix` e `work.example.nix`: sono
  esempi pubblici, non la configurazione da attivare sui tre host reali.
- La directory locale contiene `default.nix`, `home.nix` e `work.nix` con
  la stessa forma dei template. Il suo `default.nix` importa i due file
  reali e restituisce `{ home = …; work = …; }`.
- `home.nix` locale custodisce email e autore Git, rete di casa, chiavi
  pubbliche, device ID Syncthing, mount Drive e identità SSH aggiuntive.
- `work.nix` locale custodisce i dati del client VPN ufficio e gli eventuali
  checkout privati letti dal ciclo di method. Il template non ne elenca.

Non mettere qui password, token o chiavi private: gli input Nix finiscono
nel Nix store, leggibile dagli utenti locali. La consegna dei segreti veri
resta quella descritta in `kb/secrets-management.md`.

## Preparazione su ogni host

Copiare i due template nella directory locale come `home.nix` e `work.nix`,
compilarli e creare il suo `default.nix`:

```nix
{
  home = import ./home.nix;
  work = import ./work.nix;
}
```

Usare directory con permessi `0700` e file `0600`. La directory reale va
preservata nel backup privato, insieme al seed; il clone pubblico da solo
non ricostruisce le identità. `NIXOS_IDENTITY_DIR` permette di scegliere
una directory diversa, anche sotto `sudo` (il wrapper lo invoca dopo aver
risolto la directory dell'utente).

## Comandi sui propri host

Da questo checkout:

```bash
o3/scripts/con-identita.sh nix eval --raw '.#homeConfigurations."stele@deck".activationPackage.drvPath'
o3/scripts/con-identita.sh home-manager switch --flake .#stele@deck
o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake .#deck
```

Il wrapper si ferma se manca la directory locale. Aggiunge
`--override-input identity path:<directory>` e `--no-write-lock-file`:
nessun path reale entra nel lock pubblico. Switch e rebuild conservano i
confini di autorizzazione di `CLAUDE.md`. Anche `remoto allinea` richiede
l'identità già predisposta sull'host destinatario, senza inviarla da deck.

`nix flake check` senza override verifica i template pubblici. Gli update
come `nix flake update ai` usano il lock pubblico senza override; solo
valutazioni, build e attivazioni reali passano dal wrapper. Non usare
`path:.` dal checkout operativo: includerebbe anche i file ignorati.

## Storia precedente

La storia precedente alla pubblicazione è un archivio privato statico,
non un altro repository da mantenere. Il custode ha approvato il
2026-11-11 la rinomina del vecchio repository in `nixos-archivio-privato`,
archiviato e mantenuto privato, e la creazione di un nuovo `steledama/nixos`
con storia pulita. Su deck il bundle finale verificato vive in
`~/.local/share/nixos/archivio-privato/storia-prepubblicazione.bundle`; i riferimenti
storici rimasti nei nodi si consultano lì. Per esempio:

```bash
git clone ~/.local/share/nixos/archivio-privato/storia-prepubblicazione.bundle /tmp/nixos-storia
git -C /tmp/nixos-storia log --all
```

Il bundle va incluso nel backup privato e non deve entrare nel repository
pubblico, neppure come allegato, branch o tag.

Il vecchio `.git` di deck è conservato nello stesso archivio come
`git-prima-pubblicazione/`, con origin rivolto all'archivio remoto privato.
Nel checkout operativo non rimangono ref o oggetti della storia precedente.

Il passaggio è completato sui tre host. Per game e neve, i resoconti delle
sessioni locali inoltrati dal custode il 2026-11-11 attestano: clone pubblico
a `1c9da16`, identità e regole privacy identiche a deck con permessi privati,
controllo privacy senza riscontri, switch Home Manager riuscito e deriva
home allineata. SSH, mount Drive e Syncthing funzionano, senza unità utente
fallite. Sono riscontri delle sessioni locali, non verifiche remote ripetute
da deck. La manutenzione completa su game non è stata provata durante il
collaudo; resta al normale uso della ricorrenza.

Su game e neve il vecchio checkout è in `~/nixos-archivio-privato`, con
origin rivolto all'archivio remoto. I worktree precedenti sono stati
ricollegati. Quello di game conserva il commit locale non pubblicato
`6fb3d265`: il passaggio al repo pubblico non lo ha integrato né eliminato.
Il materiale va conservato privato insieme al vecchio checkout.

I sistemi attivi conservavano una revisione privata non risolvibile nel nuovo
clone. Il primo rebuild col wrapper ha poi registrato `dirty`, perché
l'override toglie `rev` a `self`: la revisione ora usa il `narHash` del
codice pubblico, e `system-drift.sh` confronta comunque il toplevel attivo
con `HEAD` (`kb/development-workflow.md`, «Tracciabilità»). Non impedisce la
chiusura della migrazione: i sistemi con revisione fissata erano identici
prima del taglio, e le home sono ora applicate e verificate.

## Controllo prima dei commit

`python3 o3/tools/privacy.py` controlla i file versionati e quelli nuovi non
ignorati, senza seguire le dipendenze esterne. Le regole private sono in
`~/.config/nixos/privacy.json`: un oggetto con `literals` (stringhe da non
pubblicare) e, facoltativamente, `patterns` (espressioni regolari). Non
versionare questo file: contiene proprio i dati da escludere. Il gate lo
esegue quando è configurato. Integrare con una scansione dei segreti, per
esempio `gitleaks dir` su un export dei soli file pubblicabili.

I commit di questo repo usano l'identità pubblica `steledama` e l'indirizzo
GitHub noreply, tramite un include Git limitato al checkout `~/nixos`.
Gli altri repo conservano l'identità personale configurata localmente.
