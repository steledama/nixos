---
stato: maturo
---

# Remoto

Lo strumento con cui una sessione su `deck` legge lo stato di `game` e
`neve` e ne allinea la home allo stesso albero di `deck`.

Da `deck` gli allineamenti home di `game` e `neve` passano da `remoto`
(`o3/modules/home/remoto.nix`, criterio `atti-remoti` di `autonomy.md`). I
comandi remoti sono fissati nello script costruito da Nix, al posto di un
`ssh` libero. `remoto` rifiuta gli host di lavoro, che vivono nel repo
`example-org/nixos-ufficio`.

- `remoto stato <host>`: `nixos-version`, generazioni di sistema e home (la
  riga `home:` è l'input di `o3/scripts/home-drift.sh`), revisione e
  toplevel del sistema attivo (righe `revisione:` e `sistema:`, input di
  `o3/scripts/system-drift.sh`), albero inviato, `HEAD` e stato di
  `~/nixos`, unità fallite di sistema e utente, e
  `~/.local/state/nixos/home.json`: i rev degli input della home attiva e
  la versione di `gogcli` dove è installato, scritti da `stato-home.nix` a
  ogni switch, di chiunque. È il fatto da cui `/manutenzione` certifica le
  liste home del registro (`ia.applicato_su`,
  `sistema.home_applicata_su`). Sola lettura.
- `remoto allinea <host>`: manda l'albero dell'index di `deck` (con
  `git write-tree`, poi `git archive`) in `~/.cache/remoto/nixos` sull'host
  e ci fa lo switch Home Manager del profilo dell'host, con
  `o3/scripts/con-identita.sh` e il flake `path:` di quella cartella,
  registrando l'albero in `~/.cache/remoto/albero`. È idempotente: un
  albero già applicato non si rimanda. Quando l'`HEAD` di `deck` porta
  quell'albero ed è su `origin`, fa anche `git pull --ff-only` di `~/nixos`
  sull'host.

Codici di uscita: `0` riuscito, `2` uso (anche un host di lavoro), `3` host non
raggiungibile, `6` su `deck` ci sono file non in staging (l'albero inviato
non sarebbe quello dello switch di `deck`); dopo uno switch riuscito, `10`
checkout remoto sporco, `11` branch remoto non `main`, `12` `HEAD` remoto
diverso dopo il pull, `13` pull fallito: lo switch vale, è solo il checkout
a restare indietro. Altrimenti il codice del comando remoto.

Il gate confronta l'albero, non la generazione: un commit di soli testi
richiede un nuovo `allinea` anche quando la home non cambia. Lo switch
dall'albero inviato dà la stessa generazione dello switch dal checkout:
`path:` e `git` costruiscono la stessa home.

Connessioni:

- [ssh-matrix](ssh-matrix.md)
- [home-manager](home-manager.md)
- [development-workflow](development-workflow.md)
