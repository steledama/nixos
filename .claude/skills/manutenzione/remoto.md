# Gli altri host da deck

Su `deck` la skill cura anche `game` e `neve`, che non la eseguono, con lo
strumento `remoto` (criterio `atti-remoti` di `autonomy.md`,
`kb/cicli.md § Atti remoti`). Fuori da `deck` valgono le regole per host dei
singoli rami. `norvegia` e `svezia` girano dal repo `example-org/nixos-ufficio` dal
2026-11-04: `remoto` li rifiuta e la skill non li cura più.

- **Stato:** `game` e `neve` restano fuori dal giro autonomo (spenti alle
  04:30): li cura il custode lanciando la skill da loro; in sessione su
  `deck`, `remoto stato <host>` li raggiunge solo se il custode dice che
  sono accesi. La riga `home.json` riporta i rev degli input da cui è
  costruita la home attiva (modulo `stato-home.nix`) e la versione di
  `gogcli` dove è installato: è il fatto da cui si certifica. Un host i cui
  rev coincidono con quelli registrati e che manca da `applicato_su` ci
  entra, chiunque abbia fatto lo switch; uno che non coincide ne esce.
- **`ia`, `home-manager`, `casa.gogcli`:** un solo commit certifica
  `deck` e gli host allineati. Dopo lo switch di `deck`: `applicato_su`
  con `deck` e gli host accesi che il ramo serve, `git add` di tutto,
  `remoto allinea <host>` su ciascuno (l'albero inviato è quello in
  staging, quindi quello del commit), via da `applicato_su` gli host
  falliti, commit e push, poi di nuovo `remoto allinea <host>` per portare
  il loro `~/nixos` al commit. Prima del commit la voce è una bozza; il
  commit certifica solo gli switch riusciti.
- **Host spento:** il codice `3` non è un errore. Non si riprova e
  l'allineamento resta in `applicato_su` come mancante. L'assenza di
  `game` e `neve` da `applicato_su` è lo stato normale fra due loro
  accensioni, non un'incertezza da riferire.
