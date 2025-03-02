# neovim/default.nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.nixvim.config = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      have_nerd_font = false;
    };

    opts = {
      number = true;
      relativenumber = true;
      mouse = "a";
      showmode = false;
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes";
      updatetime = 250;
      timeoutlen = 300;
      splitright = true;
      splitbelow = true;
      list = true;
      listchars = {
        tab = "» ";
        trail = "·";
        nbsp = "␣";
      };
      inccommand = "split";
      cursorline = true;
      scrolloff = 10;
    };

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    # Basic plugins
    plugins = {
      which-key.enable = true;
      web-devicons.enable = true;
      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
        };
      };

      # Neo-tree configurazione
      neo-tree = {
        enable = true;
        closeIfLastWindow = true;
        window = {
          position = "left";
          width = 30;
          mappings = {
            "<space>" = "none";
            "o" = "open";
            "O" = "open_with_window_picker";
            "H" = "toggle_hidden";
            "/" = "fuzzy_finder";
            "D" = "delete";
            "A" = "add_directory";
            "a" = "add";
            "c" = "copy";
            "m" = "move";
            "q" = "close_window";
          };
        };
        filesystem = {
          followCurrentFile = {
            enabled = true;
          };
          filteredItems = {
            hideDotfiles = false;
            hideByName = [
              "node_modules"
              ".git"
            ];
          };
        };
      };

      # Treesitter configurazione avanzata
      treesitter = {
        enable = true;
        settings = {
          ensure_installed = [
            "bash"
            "c"
            "diff"
            "html"
            "lua"
            "luadoc"
            "markdown"
            "markdown_inline"
            "query"
            "vim"
            "vimdoc"
            "javascript"
            "typescript"
            "python"
            "nix"
            "json"
          ];

          # Syntax highlighting
          highlight.enable = true;

          # Indentation
          indent.enable = true;

          # Incremental selection
          incremental_selection = {
            enable = true;
            keymaps = {
              init_selection = "<c-space>";
              node_incremental = "<c-space>";
              scope_incremental = "<c-s>";
              node_decremental = "<M-space>";
            };
          };
        };
      };

      # LSP configuration
      lsp = {
        enable = true;
        servers = {
          # JavaScript/TypeScript
          ts_ls.enable = true;

          # Python
          pyright.enable = true;

          # Nix
          nil_ls = {
            enable = true;
            settings = {
              formatting.command = ["nixpkgs-fmt"];
            };
          };

          # Lua
          lua_ls = {
            enable = true;
            settings.Lua = {
              completion.callSnippet = "Replace";
              diagnostics.globals = ["vim"];
            };
          };
        };

        # LSP keymaps
        keymaps = {
          lspBuf = {
            # Navigazione
            "gd" = "definition";
            "gD" = "declaration";
            "gr" = "references";
            "gI" = "implementation";

            # Informazioni
            "K" = "hover";
            "<leader>D" = "type_definition";
            "<leader>ds" = "document_symbol";
            "<leader>ws" = "workspace_symbol";

            # Azioni
            "<leader>rn" = "rename";
            "<leader>ca" = "code_action";
          };

          diagnostic = {
            "<leader>q" = "setloclist";
            "[d" = "goto_prev";
            "]d" = "goto_next";
            "<leader>e" = "open_float";
          };
        };
      };

      # Completamento automatico con cmp
      cmp = {
        enable = true;
        settings = {
          mapping = {
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-y>" = "cmp.mapping.confirm({ select = true })";
          };
          sources = [
            {name = "nvim_lsp";}
            {name = "path";}
            {name = "buffer";}
          ];
        };
      };

      # Formattazione automatica con conform.nvim
      conform-nvim = {
        enable = true;
        settings = {
          # Configurazione che prima era in extraOptions
          format_on_save = {
            __raw = ''
              function()
                return {
                  timeout_ms = 500,
                  lsp_fallback = true,
                }
              end
            '';
          };
          # Rinominato da formattersByFt a formatters_by_ft
          formatters_by_ft = {
            lua = ["stylua"];
            python = ["isort" "black"];
            javascript = ["prettierd"];
            typescript = ["prettierd"];
            nix = ["nixpkgs-fmt"];
          };
        };
      };

      # Bufferline - barra dei buffer in alto
      bufferline = {
        enable = true;
        settings = {
          options = {
            numbers = "none";
            diagnostics = "nvim_lsp";
            separator_style = "thin";
            show_buffer_icons = true;
            show_buffer_close_icons = true;
            show_close_icon = true;
            show_tab_indicators = true;
            always_show_bufferline = true;
            offsets = [
              {
                filetype = "neo-tree";
                text = "File Explorer";
                text_align = "center";
                separator = true;
              }
            ];
            indicator = {
              icon = "▎";
              style = "icon";
            };
            modified_icon = "●";
            buffer_close_icon = "󰅖";
            close_icon = "";
            left_trunc_marker = "";
            right_trunc_marker = "";
          };
        };
      };

      # Plugin per evidenziare l'indentazione
      indent-blankline = {
        enable = true;
        settings = {
          indent = {
            char = "│";
          };
          scope = {
            enabled = true;
            show_start = false;
            show_end = false;
          };
        };
      };

      # Plugin per commentare/decommentare rapidamente
      comment = {
        enable = true;
        # comment-nvim non utilizza settings in nixvim
      };

      # Aggiunge auto-pairs con nvim-autopairs
      nvim-autopairs = {
        enable = true;
      };
    };

    # Basic keymaps
    keymaps = [
      # Navigazione di base
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
      }

      # Keymap per Neo-tree
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Toggle file explorer";
      }
      {
        mode = "n";
        key = "<leader>o";
        action = "<cmd>Neotree focus<CR>";
        options.desc = "Focus file explorer";
      }

      # Keymaps per telescope
      {
        mode = "n";
        key = "<leader>sf";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "[S]earch [F]iles";
      }
      {
        mode = "n";
        key = "<leader>sg";
        action = "<cmd>Telescope live_grep<CR>";
        options.desc = "[S]earch by [G]rep";
      }
      {
        mode = "n";
        key = "<leader>sh";
        action = "<cmd>Telescope help_tags<CR>";
        options.desc = "[S]earch [H]elp";
      }
      {
        mode = "n";
        key = "<leader>sk";
        action = "<cmd>Telescope keymaps<CR>";
        options.desc = "[S]earch [K]eymaps";
      }
      {
        mode = "n";
        key = "<leader>ss";
        action = "<cmd>Telescope builtin<CR>";
        options.desc = "[S]earch [S]elect Telescope";
      }
      {
        mode = "n";
        key = "<leader>sw";
        action = "<cmd>Telescope grep_string<CR>";
        options.desc = "[S]earch current [W]ord";
      }
      {
        mode = "n";
        key = "<leader>sd";
        action = "<cmd>Telescope diagnostics<CR>";
        options.desc = "[S]earch [D]iagnostics";
      }
      {
        mode = "n";
        key = "<leader>sr";
        action = "<cmd>Telescope resume<CR>";
        options.desc = "[S]earch [R]esume";
      }
      {
        mode = "n";
        key = "<leader>s.";
        action = "<cmd>Telescope oldfiles<CR>";
        options.desc = "[S]earch Recent Files";
      }
      {
        mode = "n";
        key = "<leader><leader>";
        action = "<cmd>Telescope buffers<CR>";
        options.desc = "[ ] Find existing buffers";
      }

      # Navigazione finestre
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w><C-h>";
        options.desc = "Move focus to the left window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w><C-l>";
        options.desc = "Move focus to the right window";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w><C-j>";
        options.desc = "Move focus to the lower window";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w><C-k>";
        options.desc = "Move focus to the upper window";
      }

      # Navigazione buffers con bufferline
      {
        mode = "n";
        key = "<leader><tab>";
        action = "<cmd>BufferLineCycleNext<CR>";
        options.desc = "Next buffer";
      }
      {
        mode = "n";
        key = "<leader><S-tab>";
        action = "<cmd>BufferLineCyclePrev<CR>";
        options.desc = "Previous buffer";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = "<cmd>bdelete<CR>";
        options.desc = "Close current buffer";
      }
      {
        mode = "n";
        key = "<leader>bp";
        action = "<cmd>BufferLinePick<CR>";
        options.desc = "Pick buffer";
      }
      {
        mode = "n";
        key = "<leader>bs";
        action = "<cmd>BufferLineSortByDirectory<CR>";
        options.desc = "Sort buffers by directory";
      }

      # Formatting keymaps
      {
        mode = "n";
        key = "<leader>f";
        action = ''
          function()
            require("conform").format({
              async = true,
              lsp_fallback = true,
              timeout_ms = 500,
            })
          end
        '';
        options = {
          desc = "Format buffer";
          # Rimosso l'opzione 'lua = true' che non è supportata
        };
      }
    ];

    # Basic colorscheme
    colorschemes.tokyonight = {
      enable = true;
      settings.style = "night";
    };

    # Highlight su yank
    autoGroups = {
      kickstart_highlight_yank = {
        clear = true;
      };
    };

    autoCmd = [
      {
        event = "TextYankPost";
        group = "kickstart_highlight_yank";
        callback = {
          __raw = ''
            function()
              vim.highlight.on_yank()
            end
          '';
        };
      }
    ];

    # Configurazione aggiuntiva per assicurare che conform.nvim formatti al salvataggio
    extraConfigLua = ''
      -- Configurare conform.nvim per formato al salvataggio
      local conform = require("conform")

      -- Format on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function(args)
          conform.format({ bufnr = args.buf, timeout_ms = 500, lsp_fallback = true })
        end,
      })

      -- Configurazione commenti
      require('Comment').setup({
        padding = true,
        sticky = true,
        ignore = "^$", -- ignora linee vuote
        toggler = {
          line = "gcc",
          block = "gbc"
        },
        opleader = {
          line = "gc",
          block = "gb"
        }
      })

      -- Configurazione autopairs
      require('nvim-autopairs').setup({
        check_ts = true,
        disable_filetype = {"TelescopePrompt"},
        enable_check_bracket_line = true,
      })
    '';
  };
}
