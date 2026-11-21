# modules/home/bitwarden-cli.nix
{pkgs, ...}: {
  # Bitwarden CLI (`bw`): access to the custodian's personal vault, the seed
  # of the home secrets (kb/secrets-management.md). Only on deck, where the
  # inventory is reconciled with the vault; on a host being restored use
  # `nix shell nixpkgs#bitwarden-cli` instead.
  home.packages = [pkgs.bitwarden-cli];
}
