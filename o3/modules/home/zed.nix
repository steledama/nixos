# modules/home/zed.nix
# Zed editor - declarative configuration via xdg.configFile
# Package installed at system level (modules/system/gui-apps.nix)
{...}: {
  xdg.configFile."zed/settings.json".text = builtins.toJSON {
    ui_font_size = 16;
    buffer_font_size = 16;
    auto_update = false;
    format_on_save = "on";
    gutter = {
      line_numbers = false;
    };
    project_panel = {
      dock = "left";
    };
    terminal = {
      dock = "right";
    };

    languages = {
      Nix = {
        tab_size = 2;
        language_servers = ["nil"];
        formatter = {
          external = {
            command = "alejandra";
            arguments = ["--quiet" "-"];
          };
        };
        format_on_save = "on";
      };
      PHP = {
        tab_size = 4;
        format_on_save = "on";
        enable_language_server = true;
        language_servers = ["phpactor"];
      };
      Python = {
        tab_size = 4;
        language_servers = ["ruff"];
        formatter = {
          external = {
            command = "ruff";
            arguments = ["format" "-"];
          };
        };
        format_on_save = "on";
      };
    };

    lsp = {
      nil = {
        initialization_options = {
          formatting = {
            command = ["alejandra" "--quiet" "-"];
          };
          nix = {
            flake = {
              autoArchive = true;
            };
          };
          diagnostics = {
            enable = true;
          };
        };
      };
      phpactor = {
        command = "phpactor";
        args = ["language-server"];
      };
      ruff = {
        command = "ruff";
        args = ["server"];
      };
    };
  };
}
