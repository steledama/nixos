---
sintesi: "Le note casa/identity sono in cassaforte e rilette; resta da confrontare con deck le impronte di game."
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

## Fatto il 2026-11-12

- Note `casa/identity/default.nix`, `home.nix`, `work.nix` e
  `privacy.json` create dal custode su `deck` con uno script una tantum
  (procedura di `crea`, con controllo dei doppioni) e rilette con `nota` e
  `cmp`: nessuna differenza, cassaforte bloccata.
- **Una serie basta.** Fra `deck` e `neve` differiva solo `work.nix`, che
  serve solo a `deck` (VPN ufficio, `/etc/hosts`, `ssh-work-lan.nix`,
  `methodFetch`). Con l'identità di `deck` si valutano i toplevel e gli
  `activationPackage` di `neve` e `game`. Il custode ha allineato la
  `work.nix` di `neve` a quella di `deck`: impronte uguali sui quattro file.
- **Aggiornamento.** Basta la regola già scritta nell'inventario: la nota si
  aggiorna nello stesso momento del file, e la prova annuale confronta voci e
  file.
- `kb/secrets-management.md` dichiara le voci create, rilette e nell'elenco
  del seed.

## Resta

Con `game` acceso, il custode confronta le impronte da `deck` (fish):

```fish
diff (cd ~/.config/nixos; sha256sum identity/*.nix privacy.json | psub) (ssh game 'cd ~/.config/nixos; sha256sum identity/*.nix privacy.json' | psub); and echo "deck e game uguali"
```

Se differisce solo `work.nix`, si allinea `game` come `neve` (copia di
sicurezza, poi `scp`). Se differiscono `default.nix`, `home.nix` o
`privacy.json`, si capisce quale copia è giusta prima di toccare note o file.

## Criterio di chiusura

Impronte di `game` uguali a quelle di `deck` (dopo un eventuale
allineamento di `work.nix`) e la riga corrispondente in
`kb/secrets-management.md`. La
prova di ripristino vera resta alla ricorrenza annuale.
