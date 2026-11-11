# Ramo home-manager

- **`home-manager`** — host: tutti (`deck`/`neve`/`game`). Input: `home-manager` (segue `nixpkgs`). Lock:
  globale cross-host, cadenza in `home-manager.cadenza_giorni`. Azione:
  update + valutazione di tutte le `homeConfigurations` + eventuale
  adeguamento delle deprecazioni nei moduli home + `home-manager switch`,
  tutto autonomo. Stato: `home-manager.rev`, `home-manager.applicato_su`,
  allineamento nel [contesto](contesto.md).

Leggi `kb/home-manager.md` per la relazione con il pin nixpkgs. Confronta lock e upstream:

```bash
jq -r '.nodes["home-manager"].locked | "\(.rev) \(.lastModified)"' flake.lock
gh api repos/nix-community/home-manager/commits/master \
  --jq '.sha+" "+.commit.committer.date'
```

Prima dell’update
leggi [valutazione](valutazione.md); confronta i commit fra i due rev con
il comando home-manager in [upstream](references/upstream.md). Dopo lo
switch leggi `home-manager news` per le novità dei moduli in uso.

Confronto e valutazione sono la fase diagnosi; la sezione seguente è la fase
atti.

## Update (solo da `deck`/`neve`/`game`)

Se il rev upstream è diverso da quello nel lock:

1. `nix flake update home-manager`.
2. Valuta **tutte** le `homeConfigurations`, non solo quella dell'host
   corrente — un modulo cambiato può rompere un profilo che qui non si usa:
   `nix eval --raw '.#homeConfigurations."<utente@host>".activationPackage.drvPath'`
   per ciascuna. Errori o `trace: warning` nuovi sono il finding.
3. Deprecazioni che toccano i nostri moduli home (`o3/modules/home/`,
   `o3/home/`): adeguale subito, nello stesso giro — sono home-level e
   autonome. Un warning che viene da home-manager stesso (codice upstream)
   non si corregge qui: si risolve col prossimo bump. Un errore di
   valutazione non risolvibile con un adeguamento banale: ripristina il
   lock (`o3/scripts/ripristina-lock.sh`), registra `esito: "fallito"` con la
   nota e non committare il bump.
4. `o3/scripts/con-identita.sh home-manager switch --flake .#$USER@$(hostname)` e
   `systemctl --user --failed`.
5. Passa alla chiusura per commit e push autonomi, dopo gli allineamenti
   previsti dal nucleo: `flake.lock`, eventuali adeguamenti dei moduli e
   `i1/manutenzione.json`, messaggio `chore(home): aggiorna home-manager
(<rev corto>)` con i warning/adeguamenti nel corpo. `applicato_su`
   segue il [contesto](contesto.md).

Restituisci rev, warning, esito e host verificati alla [chiusura](chiusura.md).
Su deck segui [remoto](remoto.md) prima del commit. Il controllo
`home-drift.sh` nel contesto confronta HEAD, non il lock ancora da
committare: non usarlo per certificare il candidato sporco appena attivato.
