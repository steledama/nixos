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

La storia privata precedente al repo pubblico si conserva in due forme:

- `steledama/nixos-archivio-privato` su GitHub, privato e archiviato:
  conserva la vecchia storia pubblicata, senza sincronizzazioni future;
- un solo bundle su deck:
  `~/.local/share/nixos/archivio-privato/storia-prepubblicazione.bundle`.
  Il file privato `LEGGIMI.txt` accanto al bundle contiene checksum e
  istruzioni di ripristino. Il bundle comprende anche i commit presenti
  solo nelle ref o nei reflog dei vecchi checkout dei tre host, incluso
  `6fb3d265` di game, che non è nell'archivio GitHub.

Consolidamento verificato il 2026-11-11: 2316 commit, clone mirror di prova
e `git fsck --full` riusciti. Vecchio `.git` di deck, bundle superato,
patch duplicata e copie temporanee della pubblicazione rimossi. Il bundle
va incluso nel backup privato; non entra nel repo pubblico, neppure come
allegato, branch o tag.

Per consultare la storia senza riattivare un checkout da mantenere:

```bash
git clone ~/.local/share/nixos/archivio-privato/storia-prepubblicazione.bundle /tmp/nixos-storia
git -C /tmp/nixos-storia log --all
```

Prima di eliminare vecchi checkout sugli altri host, verificare nella
sessione locale ref, reflog, stash, modifiche e file ignorati di ogni
worktree. Il consolidamento copre i commit letti quel giorno, non nuovi
cambiamenti o file mai committati. Rimuovere i worktree con Git prima del
checkout che li registra. Le identità in `~/.config/nixos/` e il clone
pubblico operativo restano necessari e non si eliminano.

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
