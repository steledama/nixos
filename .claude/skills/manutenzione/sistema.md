# Ramo sistema

- **`sistema`**: vale per `deck`, `neve` e `game`.
  - Input: `nixpkgs`, che serve sistema e home dei tre host, e `home-manager`, che segue `nixpkgs` e porta il codice dei moduli home, non pacchetti.
  - Cadenza: `sistema.cadenza_giorni`, settimanale, con lock cross-host.
  - Stato: `sistema.nixpkgs_rev`, `sistema.home_manager_rev`, `sistema.host_controllato`, `sistema.home_applicata_su` (switch home) e `sistema.applicato_su` (rebuild).
  - Porta anche **`sistema.gogcli`**, l'overlay permanente con pin unico in `flake.nix`, oggi installato solo su `deck`. Ha `da`/`a`/`esito`/`nota` propri, ma condivide data, cadenza e switch home del ramo.
  - Le voci per host stanno in `sistema.host_specifico` ([host](host.md)).

I due input si aggiornano insieme: `home-manager` master segue nixpkgs
unstable, e spostarne uno solo lascerebbe moduli e pacchetti di settimane
diverse. Il livello dei pacchetti (`kb/configuration-patterns.md`) decide
chi attiva: la home la attiva l'agente, il sistema il custode.

## Diagnosi

Sola lettura, sull'host rappresentante:

1. `o3/scripts/system-versions.sh` confronta il pin con unstable, per i
   pacchetti di sistema e per le app della home che leggono lo stesso pin.
   Per i controlli per host e le voci host-specifiche leggi [host](host.md).
2. Confronta `home-manager` fra lock e upstream:

   ```bash
   jq -r '.nodes["home-manager"].locked | "\(.rev) \(.lastModified)"' flake.lock
   gh api repos/nix-community/home-manager/commits/master \
     --jq '.sha+" "+.commit.committer.date'
   ```

   Se il rev cambia, leggi i titoli dei commit fra i due rev con il
   comando home-manager di [upstream](references/upstream.md).

3. gogcli: confronta il pin con l'ultima release di `openclaw/gogcli`, non
   con nixpkgs (comando in [upstream](references/upstream.md));
   `system-versions.sh` non lo include. Un delta azionabile segue
   [overlay](overlay.md).
4. Leggi [valutazione](valutazione.md) per changelog, rischio e cache. Kernel
   e Chromium richiedono la fonte letta, non un riassunto.

La diagnosi decide la fase atti:

- **Nessun rischio alto:** si procede con gli atti.
- **Rischio alto:** il pin non si sposta. Registra la diagnosi
  (`esito: "diagnosticato"`), presenta il finding al custode e segui la
  [promozione](chiusura.md#promozione-dei-finding). gogcli, che non dipende
  dal pin, può procedere da solo.
- **Nessun delta** su entrambi gli input e su gogcli: registra
  `esito: "nessun_delta"`, senza update né switch.

## Atti

1. `nix flake update nixpkgs home-manager`, più l'eventuale bump di gogcli.
2. Valuta **tutte** le `homeConfigurations` e i tre `nixosConfigurations`,
   non solo quelli dell'host corrente:
   `nix eval --raw '.#homeConfigurations."<utente@host>".activationPackage.drvPath'`
   e `.#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`,
   con `o3/scripts/con-identita.sh` davanti. Errori o `trace: warning`
   nuovi sono il finding.
3. Deprecazioni nei nostri moduli home (`o3/modules/home/`, `o3/home/`):
   adeguale nello stesso giro, sono home-level. Un adeguamento nei moduli di
   sistema si prepara e si committa, ma l'attiva il rebuild del custode. Un
   warning che viene dal codice upstream si risolve con un bump successivo.
   Un errore non risolvibile con un adeguamento banale: ripristina il lock
   (`o3/scripts/ripristina-lock.sh`), registra `esito: "fallito"` con la nota
   e non committare il bump.
4. `o3/scripts/con-identita.sh home-manager switch --flake .#$USER@$(hostname)`
   e `systemctl --user --failed`. Dopo lo switch leggi `home-manager news`
   per le novità dei moduli in uso.
5. Su `deck`, gli altri host accesi seguono [remoto](remoto.md) prima del
   commit.
6. Commit e push autonomi con la [chiusura](chiusura.md): `flake.lock`, gli
   adeguamenti dei moduli e `i1/manutenzione.json`, messaggio
   `chore(flake): aggiorna nixpkgs e home-manager (<rev corti>)`, con
   pacchetti principali, rischi e warning nel corpo.
7. Rebuild: fornisci al custode il comando minimo per ogni host,
   `o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake .#<host>`,
   costruendo prima il sistema dell'host corrente con `nix build` per
   segnalare compilazioni locali. Il rebuild non si esegue né si propone di
   eseguirlo con `sudo` dall'agente.

Fra lo switch della home e il rebuild, la home è più avanti del sistema: per
i driver grafici è la direzione sicura. Il controllo `home-drift.sh` del
[contesto](contesto.md) confronta HEAD, non il lock ancora da committare: non
usarlo per certificare il candidato appena attivato.

Restituisci alla [chiusura](chiusura.md) rev, delta, rischio, warning, esito
dello switch, host verificati e rebuild pendenti.
