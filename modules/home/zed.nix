# modules/home/zed.nix
# Zed editor minimal configuration
{ pkgs, ... }: {
  # Install Zed editor with needed language servers
  home.packages = with pkgs; [
    zed
    package-version-server
    nodePackages.vscode-langservers-extracted # HTML/CSS/JSON/ESLint
  ];
  
  # Create initial settings.json only if it doesn't exist yet
  home.activation.setupZedConfig = ''
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
    }
  }
}
EOF
    fi
  '';
}
