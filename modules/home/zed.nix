# modules/home/zed.nix
# Zed editor configuration
#
# IMPORTANTE: La configurazione di Zed è gestita in modo ibrido per permettere
# modifiche runtime dall'editor mantenendo una base declarative.
# 
# - I language server sono installati tramite NixOS (phpactor, nil, etc.)
# - Il file settings.json iniziale viene copiato da config-examples/zed-settings-reference.json
# - Per aggiornamenti strutturali, modificare config-examples/zed-settings-reference.json e ricostruire
# 
# Workflow:
# 1. Modifica config-examples/zed-settings-reference.json (con syntax highlighting)
# 2. Ricostruisci il sistema per applicare le modifiche al template iniziale
# 3. Il file utente (~/.config/zed/settings.json) rimane modificabile da Zed
# 
# File di riferimento: ~/.config/zed/settings.json (modificabile da Zed)
{
  pkgs,
  lib,
  ...
}: {
  # Install Zed editor with needed language servers
  home.packages = with pkgs; [
    zed-editor
    package-version-server
    phpactor # PHP language server
    nodePackages.intelephense # Alternative PHP language server
    # nodePackages.vscode-langservers-extracted # HTML/CSS/JSON/ESLint
  ];

  # Create initial settings.json from reference file only if it doesn't exist yet
  home.activation.setupZedConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ZED_CONFIG_DIR="$HOME/.config/zed"
        ZED_SETTINGS="$ZED_CONFIG_DIR/settings.json"
        ZED_REFERENCE="${../../config-examples/zed-settings-reference.json}"

        if [ ! -d "$ZED_CONFIG_DIR" ]; then
          $DRY_RUN_CMD mkdir -p "$ZED_CONFIG_DIR"
        fi

        if [ ! -f "$ZED_SETTINGS" ]; then
          $DRY_RUN_CMD cp "$ZED_REFERENCE" "$ZED_SETTINGS"
          echo "Zed: Configurazione iniziale copiata da config-examples/zed-settings-reference.json"
        fi
  '';
}