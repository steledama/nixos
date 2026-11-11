---
stato: maturo
---

# Common commands

Reference rapida per i comandi ricorrenti della configurazione NixOS. Le
procedure critiche hanno nodi dedicati separati.

## Gestione sistema

### NixOS

```bash
nix flake update nixpkgs         # sistemi e home degli host
nix flake update ai              # stack agentico Home Manager
nix flake update home-manager    # moduli Home Manager
# Whisper: modificare prima la revisione esplicita in flake.nix (vedi nix-flakes)
nix flake update nixpkgs-whisper # aggiorna il lock alla revisione scelta
o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake .
o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake .#hostname
o3/scripts/con-identita.sh sudo nixos-rebuild boot --flake .
o3/scripts/con-identita.sh nixos-rebuild build --flake .
nix-collect-garbage --delete-old
sudo nix-collect-garbage -d
sudo /run/current-system/bin/switch-to-configuration boot
```

### Home Manager

```bash
o3/scripts/con-identita.sh home-manager switch --flake .#username@hostname

# Esempi
o3/scripts/con-identita.sh home-manager switch --flake .#stele@deck
o3/scripts/con-identita.sh home-manager switch --flake .#stele@neve
o3/scripts/con-identita.sh home-manager switch --flake .#stele@game

home-manager generations
home-manager switch --rollback
nix-collect-garbage --delete-old
```

### Aggiornamento combinato

```bash
o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake . && \
  o3/scripts/con-identita.sh home-manager switch --flake .#username@hostname
```

## Validazione locale

```bash
o3/tools/check.sh
o3/tools/check.sh --flake
python3 o3/tools/kb_tools.py audit --format markdown
nix flake check
```

`o3/tools/check.sh` è il comando predefinito per una review non distruttiva senza sudo. L'opzione `--flake` include anche la validazione flake; le build NixOS dei singoli host restano comandi separati.

## Git

```bash
git status
git diff
git add <file>
git commit -m "description"
git push                       # dopo ogni commit riuscito; --force solo su richiesta
```

Non usare `nix flake update` senza indicare un input: i pin hanno cadenze e
perimetri diversi, e uno è chirurgico (`nixpkgs-whisper`).
Il workflow completo vive in `nix-flakes`.

Connessioni:

- [development-workflow](development-workflow.md)
- [nixos-rebuild](nixos-rebuild.md)
- [troubleshooting](troubleshooting.md)
- [home-manager](home-manager.md)
- [nix-flakes](nix-flakes.md)
