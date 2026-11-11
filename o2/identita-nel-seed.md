---
sintesi: "Le note casa/identity esistono in cassaforte, rilette contro i file, e l'inventario non le dichiara più da creare."
ciclo: runtime
---

# Mettere l'identità locale nel seed

## Perché

Dal 2026-11-11 il flake pubblico usa i template di `o3/identity/` e gli host
rifiutano di attivarli: senza `~/.config/nixos/identity/` un host non si
ricostruisce. La directory non è in Git e non era nel seed: l'unica copia
sta sugli host stessi. Il custode ha scelto la cassaforte Bitwarden personale
(2026-11-11). Inventario e procedura di ripristino sono già scritti
(`kb/secrets-management.md`, «Identità separata dai segreti»;
`kb/post-installation.md`, «Identità locale, prima di ogni build») e
dichiarano le note «da creare».

## Atti del custode

Nel proprio terminale su `deck`, non in una sessione con un agente:

```bash
export BW_SESSION=$(bw unlock --raw)
crea() { # nome della nota, file
  jq -n --arg n "$1" --rawfile t "$2" \
    '{type:2, secureNote:{type:0}, name:$n, notes:$t}' | bw encode | bw create item >/dev/null
}
for f in default.nix home.nix work.nix; do
  crea "casa/identity/$f" ~/.config/nixos/identity/$f
done
crea casa/identity/privacy.json ~/.config/nixos/privacy.json
bw sync
```

Rilettura, con la funzione `nota` di `kb/post-installation.md`: ogni
confronto deve tacere.

```bash
for f in default.nix home.nix work.nix; do
  nota "casa/identity/$f" | cmp - ~/.config/nixos/identity/$f
done
nota casa/identity/privacy.json | cmp - ~/.config/nixos/privacy.json
bw lock
```

I comandi non sono stati provati contro la cassaforte. `jq --rawfile`
conserva il newline finale del file e `nota` lo restituisce: se `cmp`
segnala solo l'ultimo byte, la differenza è lì.

## Da verificare prima di chiudere

- **Una serie o una per host.** Le note sono prese da `deck`. Con `game` e
  `neve` accesi, confrontare le impronte dei tre file sui tre host
  (`sha256sum ~/.config/nixos/identity/*.nix`, da leggere via SSH dal
  custode: `remoto` non lo espone). Se differiscono, le voci diventano
  `casa/<host>/identity/…` e inventario e runbook vanno adeguati.
- **Aggiornamento.** I file cambiano a mano a ogni cambio d'assetto: decidere
  se basta la regola scritta nell'inventario (aggiornare la nota nello stesso
  momento) o se serve un controllo, per esempio un'impronta registrata da
  confrontare nella prova annuale.

## Criterio di chiusura

Note create e rilette senza differenze, questione «una serie o una per host»
risolta, `kb/secrets-management.md` aggiornato: via «da creare», data della
rilettura nella voce, le voci `casa/identity/…` nell'elenco del seed. La
prova di ripristino vera resta alla ricorrenza annuale.
