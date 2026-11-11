# Bump overlay

**Bump pacchetti overlay (ex `/overlay`)**: quando la [valutazione](valutazione.md) trova un
delta azionabile su un pacchetto overlay-ato in `flake.nix` (oggi `gogcli`
e `whisper-cpp`), esegui il bump della **definizione**, non
l'attivazione. Il passo 1 e la lettura delle note stanno nella fase diagnosi,
gli altri nella fase atti:

1. Verifica l'ultima release sull'upstream reale del pacchetto (repo
   GitHub del progetto, non nixpkgs — per `gogcli` è `openclaw/gogcli`, non
   l'attributo `gogcli` di nixpkgs, fermo a `0.11.0`).
2. Aggiorna `version` nell'overlay in `flake.nix`.
3. Refresh hash: imposta temporaneamente un hash placeholder
   (`sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=`) su `src`
   (`fetchFromGitHub`) e, se Go, su `vendorHash`; builda l'espressione
   realmente usata (home o system, es.
   `nix build --impure --no-link --expr '...'` sul pacchetto in
   `homeConfigurations`/`nixosConfigurations`) e copia l'hash `got:`
   dall'errore di mismatch.
4. Vincolo toolchain (es. Go): se il nuovo `go.mod` upstream richiede una
   patch-version più recente di quella in `nixpkgs`, usa un `postPatch`
   minimale con commento che cita la soglia da cui rimuoverlo — non per
   salti di versione linguaggio reali, solo per gap di patch-level.
5. Valida: build dell'espressione più eventuali `passthru.tests`; poi
   `alejandra flake.nix`.
6. **Attivazione**, secondo il confine di `CLAUDE.md` — qui, e non prima,
   la meccanica smette di essere autonoma per i pacchetti di sistema:
   - home-level (`gogcli`): `o3/scripts/con-identita.sh home-manager switch --flake .#$USER@$(hostname)`,
     autonomo, nessuna conferma.
   - system-level (`whisper-cpp`): fermati dopo la diagnosi
     — non lanciare `nixos-rebuild`. Il bump della definizione (`flake.nix`
     - `flake.lock` se l'input dedicato è cambiato) resta comunque
       autonomo e committabile (stesso principio della [promozione](chiusura.md#promozione-dei-finding): bump del pin
       non-sudo, rebuild separato autorizzato).
7. Passa alla chiusura, dopo gli allineamenti previsti dal nucleo,
   per commit e push autonomi del bump (stesso principio di `ia` e della
   [registrazione](chiusura.md): l'invocazione di `/manutenzione` è l'autorizzazione esplicita)
   — `chore(<home|flake>): aggiorna <pacchetto> a <versione>`, corpo con
   nota su cosa è stato validato (build, `passthru.tests`, switch se
   applicato).
