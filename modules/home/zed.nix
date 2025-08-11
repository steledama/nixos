# modules/home/zed.nix
# Zed editor configuration
#
# IMPORTANTE: La configurazione di Zed è gestita in modo ibrido per permettere
# modifiche runtime dall'editor mantenendo una base declarative.
# 
# - I language server sono installati tramite NixOS (phpactor, nil, etc.)
# - Il file settings.json iniziale viene creato ma poi rimane modificabile da Zed
# - Per aggiornamenti strutturali, modificare il template qui sotto e ricostruire
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

  # Create initial settings.json only if it doesn't exist yet
  home.activation.setupZedConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ZED_CONFIG_DIR="$HOME/.config/zed"
        ZED_SETTINGS="$ZED_CONFIG_DIR/settings.json"

        if [ ! -d "$ZED_CONFIG_DIR" ]; then
          $DRY_RUN_CMD mkdir -p "$ZED_CONFIG_DIR"
        fi

        if [ ! -f "$ZED_SETTINGS" ]; then
          $DRY_RUN_CMD cat > "$ZED_SETTINGS" << 'EOF'
    {
      "format_on_save": "on",
      "languages": {
        "Nix": {
          "tab_size": 2,
          "formatter": {
            "external": {
              "command": "alejandra",
              "arguments": ["--quiet", "-"]
            }
          },
          "format_on_save": "on"
        },
        "PHP": {
          "tab_size": 4,
          "format_on_save": "on",
          "enable_language_server": true,
          "language_servers": ["phpactor"]
        }
      },
      "lsp": {
        "nil": {
          "initialization_options": {
            "formatting": {
              "command": ["alejandra", "--quiet", "-"]
            },
            "nix": {
              "flake": {
                "autoArchive": true
              }
            }
          }
        },
        "phptools": {
          "initialization_options": {},
          "settings": {}
        },
        "phpactor": {
          "command": "phpactor",
          "args": ["language-server"]
        }
      }
    }
    EOF
        fi
  '';
}
