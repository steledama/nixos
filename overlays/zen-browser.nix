# overlays/zen-browser.nix
# Questo overlay aggiunge il pacchetto zen-browser dagli input del flake.

inputs: (final: prev: {
  zen-browser = inputs.zen-browser.packages.${prev.system}.default;
})
