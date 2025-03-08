# nixos/modules/home/yazi.nix
{ pkgs, ... }: {
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    # Configurazione principale
    settings = {
      manager = {
        layout = [ 1 3 4 ]; # Distribuzione dei pannelli
        sort_by = "natural"; # Ordinamento naturale dei file
        sort_sensitive = false; # Ignora maiuscole/minuscole nell'ordinamento
        sort_reverse = false; # Non invertire l'ordinamento
        sort_dir_first = true; # Directory prima dei file
        linemode = "size"; # Mostra dimensione file nella lista
        show_hidden = false; # Non mostrare file nascosti di default
        show_symlink = true; # Mostra i symlink
      };

      preview = {
        tab_size = 2; # Dimensione tab per preview codice
        max_width = 1200; # Larghezza massima preview
        max_height = 1800; # Altezza massima preview
        cache_dir = ""; # Directory cache (vuoto usa il default)
      };

      opener = {
        # Configurazione opener di default per tipi di file comuni
        text = [
          { exec = "nvim \"$@\""; block = true; }
        ];
        image = [
          { exec = "xdg-open \"$@\""; }
        ];
        video = [
          { exec = "xdg-open \"$@\""; }
        ];
        audio = [
          { exec = "xdg-open \"$@\""; }
        ];
        pdf = [
          { exec = "xdg-open \"$@\""; }
        ];
        archive = [
          { exec = "xdg-open \"$@\""; }
        ];
      };
    };

    # Tema personalizzato simile a OneDark
    theme = {
      manager = {
        cwd = { fg = "#61afef"; };
        hovered = { fg = "#ffffff"; bg = "#3e4452"; };
        preview_hovered = { underline = true; };

        # Stile dei file in base al tipo
        find_keyword = { fg = "#c678dd"; bold = true; };
        find_position = { fg = "#56b6c2"; dim = true; };

        marker_selected = { fg = "#98c379"; bold = true; };
        marker_copied = { fg = "#e5c07b"; bold = true; };
        marker_cut = { fg = "#e06c75"; bold = true; };

        tab_active = { fg = "#61afef"; bg = "#3e4452"; };
        tab_inactive = { fg = "#abb2bf"; bg = "#282c34"; };
        tab_width = 1;

        border_symbol = "│";
        border_style = { fg = "#545862"; };

        # Icone per tipi di file
        icon_file = { fg = "#abb2bf"; };
        icon_dir = { fg = "#61afef"; };
        icon_exe = { fg = "#98c379"; };
        icon_link = { fg = "#c678dd"; };
        icon_image = { fg = "#e5c07b"; };
        icon_video = { fg = "#e06c75"; };
        icon_music = { fg = "#56b6c2"; };
        icon_archive = { fg = "#d19a66"; };
      };

      status = {
        separator_open = "";
        separator_close = "";
        separator_style = { fg = "#545862"; };

        # Barra di stato
        mode_normal = { fg = "#282c34"; bg = "#98c379"; bold = true; };
        mode_select = { fg = "#282c34"; bg = "#61afef"; bold = true; };
        mode_unset = { fg = "#282c34"; bg = "#e5c07b"; bold = true; };

        progress_label = { fg = "#abb2bf"; bold = true; };
        progress_normal = { fg = "#61afef"; bg = "#3e4452"; };
        progress_error = { fg = "#e06c75"; bg = "#3e4452"; };

        permissions_t = { fg = "#98c379"; };
        permissions_r = { fg = "#61afef"; };
        permissions_w = { fg = "#e5c07b"; };
        permissions_x = { fg = "#e06c75"; };
        permissions_s = { fg = "#c678dd"; };
      };

      input = {
        border = { fg = "#61afef"; };
        title = { fg = "#abb2bf"; bold = true; };
        value = { fg = "#abb2bf"; };
        selected = { reversed = true; };
      };

      select = {
        border = { fg = "#61afef"; };
        active = { fg = "#ffffff"; bg = "#3e4452"; };
        inactive = { fg = "#abb2bf"; };
      };

      tasks = {
        border = { fg = "#61afef"; };
        title = { fg = "#abb2bf"; bold = true; };

        # Stato dei task
        hovered = { underline = true; };

        # Stile dei messaggi di task
        icon_ready = { fg = "#98c379"; };
        icon_running = { fg = "#e5c07b"; };
        icon_failed = { fg = "#e06c75"; };
        icon_done = { fg = "#61afef"; };

        # Barra di avanzamento dei task
        progress_label = { fg = "#abb2bf"; };
        progress_normal = { fg = "#61afef"; bg = "#3e4452"; };
        progress_error = { fg = "#e06c75"; bg = "#3e4452"; };
      };
    };

    # Scorciatoie di tastiera personalizzate
    keymap = {
      manager = {
        prepend_keymap = [
          # Navigazione
          { on = [ "h" ]; run = "cd .."; desc = "Go up"; }
          { on = [ "l" ]; run = "open"; desc = "Open file or enter directory"; }
          { on = [ "j" ]; run = "arrow down"; desc = "Move cursor down"; }
          { on = [ "k" ]; run = "arrow up"; desc = "Move cursor up"; }
          { on = [ "g" "g" ]; run = "arrow top"; desc = "Go to the top"; }
          { on = [ "G" ]; run = "arrow bottom"; desc = "Go to the bottom"; }
          { on = [ "H" ]; run = "seek home"; desc = "Go to the first non-hidden file"; }
          { on = [ "L" ]; run = "seek end"; desc = "Go to the last file"; }

          # Azioni sui file
          { on = [ "d" "d" ]; run = "cut selected"; desc = "Cut selected files"; }
          { on = [ "y" "y" ]; run = "copy selected"; desc = "Copy selected files"; }
          { on = [ "p" ]; run = "paste"; desc = "Paste files"; }
          { on = [ "P" ]; run = "paste --force"; desc = "Paste files (overwrite)"; }
          { on = [ "a" ]; run = "select_all"; desc = "Select all files"; }
          { on = [ "u" ]; run = "clear_selection"; desc = "Clear selection"; }
          { on = [ "r" ]; run = "rename"; desc = "Rename file"; }
          { on = [ "D" ]; run = [ "remove"; "escape --visual --select" ]; desc = "Delete files"; }
          { on = [ "c" "c" ]; run = "copy_filename"; desc = "Copy filename"; }
          { on = [ "c" "p" ]; run = "copy_filepath"; desc = "Copy filepath"; }

          # Visualizzazione
          { on = [ "." ]; run = "toggle_hidden"; desc = "Toggle hidden files"; }
          { on = [ "s" ]; run = "search"; desc = "Search files"; }
          { on = [ "S" ]; run = "search --regex"; desc = "Search files (regex)"; }
          { on = [ "c" "t" ]; run = "toggle_preview"; desc = "Toggle preview"; }

          # Comandi
          { on = [ ":" ]; run = "shell_menu"; desc = "Open shell menu"; }
          { on = [ "!" ]; run = "spawn_shell"; desc = "Spawn shell"; }
          { on = [ "z" ]; run = "jump zoxide"; desc = "Jump with zoxide"; }

          # Integrazione neovim
          { on = [ "e" ]; run = "shell 'nvim \"$@\"' --"; desc = "Edit file in neovim"; }
        ];
      };
    };
  };
}
