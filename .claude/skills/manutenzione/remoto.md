# Gli altri host da deck

Su `deck` la skill cura anche `game` e `neve`, che non la eseguono, con lo
strumento `remoto` (criterio `atti-remoti` di `autonomy.md`,
`kb/remoto.md`). Fuori da `deck` valgono le regole per host dei
singoli rami. `norvegia` e `svezia` girano dal repo `example-org/nixos-ufficio` dal
2026-11-04: `remoto` li rifiuta e la skill non li cura più.

Per preparare un aggiornamento di sistema in sessione col custode,
eseguire eval e build sul destinatario via SSH, secondo
`CLAUDE.md` «Eval e build sull'host destinatario» e il criterio
`preparazione-remota` di `autonomy.md`. Il lock si prepara su deck;
game e neve usano i propri checkout, identità e store. Non costruire
per default i loro sistemi su deck. Gli switch home remoti usano
`remoto`.

- **Stato:** `game` e `neve` sono spesso spenti. In sessione su `deck`,
  `remoto stato <host>` li raggiunge solo se il custode dice che sono
  accesi; altrimenti il custode lancia la skill da loro. La riga `home.json` riporta i rev degli input da cui è
  costruita la home attiva (modulo `stato-home.nix`) e la versione di
  `gogcli` dove è installato: è il fatto da cui si certifica. Un host i cui
  rev coincidono con quelli registrati e che manca dalla lista home del ramo
  (`ia.applicato_su`, `sistema.home_applicata_su`) ci entra, chiunque abbia
  fatto lo switch; uno che non coincide ne esce. Per `sistema` contano i rev
  di `nixpkgs` e `home-manager` e, dove installato, la versione di `gogcli`.
- **`ia` e la home di `sistema`:** un solo commit certifica
  `deck` e gli host allineati. Dopo lo switch di `deck`: la lista home
  con `deck` e gli host accesi che il ramo serve, `git add` di tutto,
  `remoto allinea <host>` su ciascuno (l'albero inviato è quello in
  staging, quindi quello del commit), via dalla lista gli host
  falliti, commit e push, poi di nuovo `remoto allinea <host>` per portare
  il loro `~/nixos` al commit. Prima del commit la voce è una bozza; il
  commit certifica solo gli switch riusciti.
- **Host spento:** il codice `3` non è un errore. Non si riprova e
  l'allineamento resta nella lista come mancante. L'assenza di
  `game` e `neve` dalle liste è lo stato normale fra due loro
  accensioni, non un'incertezza da riferire.
