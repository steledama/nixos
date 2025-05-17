# modules/home/zed.nix
{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    zed
    nil      # Nix Language Server
    alejandra  # Nix formatting
  ];

  xdg.configFile."zed/settings.json".text = ''
    {
      "ui_font_size": 16,
      "buffer_font_size": 16,
      "theme": {
        "mode": "system",
        "light": "One Dark",
        "dark": "One Dark"
      },
      "auto_update": false,
      "format_on_save": "on",
      "formatter": "language_server",
      "language_overrides": {
        "Nix": {
          "formatter": {
            "external": {
              "command": "alejandra"
            }
          }
        }
      },
      "lsp": {
        "nil": {
          "command": "nil",
          "args": [
            "--stdio"
          ],
          "settings": {
            "nil": {
              "autoArchive": true,
              "diagnostics": {
                "enable": true
              },
              "formatting": {
                "command": ["alejandra"]
              }
            }
          }
        }
      }
    }
  '';
}
