# modules/home/helix.nix
{pkgs, ...}: {
  # Helix editor with auto-format on save
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      keys.normal = {
        "C-r" = ":reload"; # ricarica il buffer se il file è cambiato fuori da Helix
      };

      editor = {
        clipboard-provider = "termcode"; # OSC 52 - funziona via SSH, herdr e desktop (Ghostty lo supporta)
        line-number = "relative";
        bufferline = "always"; # mostra sempre in alto il nome del buffer
        color-modes = true; # cambia il colore della status line a seconda della modalità
        auto-format = true; # Global auto-format on save
        soft-wrap.enable = true; # Soft wrap per ritorno a capo visuale
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
    };

    # Language-specific formatter configuration
    # Formatters are installed in modules/home/dev-tools.nix
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.alejandra}/bin/alejandra";
        }
        {
          name = "markdown";
          auto-format = true;
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = ["--parser" "markdown"];
          };
        }
        {
          name = "javascript";
          auto-format = true;
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = ["--parser" "babel"];
          };
        }
        {
          name = "typescript";
          auto-format = true;
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = ["--parser" "typescript"];
          };
        }
        {
          name = "python";
          auto-format = true;
          formatter = {
            command = "${pkgs.ruff}/bin/ruff";
            args = ["format" "-"];
          };
        }
        {
          name = "json";
          auto-format = true;
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = ["--parser" "json"];
          };
        }
        {
          name = "yaml";
          auto-format = true;
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = ["--parser" "yaml"];
          };
        }
        {
          name = "css";
          auto-format = true;
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = ["--parser" "css"];
          };
        }
        {
          name = "html";
          auto-format = true;
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = ["--parser" "html"];
          };
        }
        # PHP LSP (intelephense) is proprietary - not included
        # To enable: add nodePackages.intelephense to dev-tools.nix and set nixpkgs.config.allowUnfree = true
        # Free alternative: phpactor (install separately if needed)
        {
          name = "docker-compose";
          auto-format = true;
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = ["--parser" "yaml"];
          };
        }
      ];
    };
  };
}
