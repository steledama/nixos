---
stato: maturo
---

# Unfree packages

Policy globale: `allowUnfree = false`. Il predicate `allowUnfreePredicate` è
definito una volta per livello, in `o3/modules/system/unfree.nix` e nel
gemello home `o3/modules/home/unfree.nix`, e accetta i nomi dichiarati nella
lista mergeable `unfree.allowedNames` del proprio livello. Ogni modulo o host che
installa un pacchetto proprietario dichiara lì i nomi, con commento `# UNFREE:`.
Nessun software non-libero entra silenziosamente. Principio guida:
`method/design-principles.md`.

## Fonti dei nomi ammessi

I nomi esatti vivono nei moduli che installano i pacchetti:

- `o3/modules/home/gui-apps.nix` — browser con Widevine nella home dei tre host;
- `o3/modules/system/hardware/nvidia.nix` — driver e librerie CUDA su game;
- `o3/modules/system/gaming.nix` — Steam su game;
- `o3/hosts/neve/default.nix` — unrar su neve.

Le abbreviazioni di famiglia non sono wildcard autorizzate: il predicate
confronta i nomi della lista dichiarata. Per un inventario esatto leggere
`unfree.allowedNames` dei moduli importati dall'host.

## Import nixpkgs separati

Il predicate di sistema non governa automaticamente gli import isolati del
flake. `flake.nix` dichiara due eccezioni esplicite:

- `pkgs-ai`, con `allowUnfree = true` per Claude Code;
- l'import di `nixpkgs-whisper`, con `allowUnfree = true` e `cudaSupport = true`
  per costruire Whisper CUDA sul suo pin dedicato.

I profili Home Manager standalone leggono il pin `nixpkgs` comune: il predicate
home imposta `nixpkgs.config`, e Home Manager reimporta nixpkgs con quella
config e con gli overlay condivisi che `mkHome` ridichiara in `flake.nix`. Gli
import sopra conservano la propria configurazione.

## Aggiungere un pacchetto

1. Dichiarare il nome in `unfree.allowedNames` nel modulo che lo installa.
2. Aggiungere il commento `# UNFREE:` con il motivo.
3. Verificare la build dell'host interessato e aggiornare questa mappa solo
   se cambia il confine della policy, evitando una seconda lista di nomi.

Connessioni:

- [design-principles](../method/design-principles.md)
- [hardware-inventory](hardware-inventory.md)
