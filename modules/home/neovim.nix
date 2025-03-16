# nixos/module/home/neovim.nix
{ ... }:
let
  keymapsModule = import ./neovim-keymaps.nix { };
in
{
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
      showmode = true;
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

    plugins = {
      which-key = {
        enable = true;
        settings = {
          plugins = {
            marks = true;
            registers = true;
            spelling = {
              enabled = true;
            };
            presets = {
              operators = true;
              motions = true;
              text_objects = true;
              windows = true;
              nav = true;
              z = true;
              g = true;
            };
          };
          show_help = true;
          show_keys = true;
        };
      };

      web-devicons.enable = true;

      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
        };
      };

      neo-tree = {
        enable = true;
        closeIfLastWindow = true;
        window = {
          position = "left";
          width = 30;
          # NEO-TREE keymaps
          mappings = {
            "<space>" = "none";
            "o" = "open";
            "O" = "open_with_window_picker";
            "<C-h>" = "toggle_hidden";
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
            # INCREMENTAL keymaps
            keymaps = {
              init_selection = "<c-space>";
              node_incremental = "<c-space>";
              scope_incremental = "<c-s>";
              node_decremental = "<M-space>";
            };
          };
        };
      };

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
              formatting.command = [ "nixpkgs-fmt" ];
            };
          };
          # Lua
          lua_ls = {
            enable = true;
            settings.Lua = {
              completion.callSnippet = "Replace";
              diagnostics.globals = [ "vim" ];
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

      cmp = {
        enable = true;
        settings = {
          # CMP keymaps
          mapping = {
            "<C-Down>" = "cmp.mapping.select_next_item()";
            "<C-Up>" = "cmp.mapping.select_prev_item()";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
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
          formatters_by_ft = {
            lua = [ "stylua" ];
            python = [ "isort" "black" ];
            javascript = [ "prettierd" ];
            typescript = [ "prettierd" ];
            nix = [ "nixpkgs-fmt" ];
          };
        };
      };

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

      comment = {
        enable = true;
      };

      nvim-autopairs = {
        enable = true;
      };
    };

    # Keymaps imported form neovim-keymaps.nix
    keymaps = keymapsModule.keymaps;

    # Basic colorscheme
    colorschemes.tokyonight = {
      enable = true;
      settings.style = "night";
    };

    # Highlight on yank
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

    # Extra config conform.nvim format on save
    extraConfigLua = ''
      local conform = require("conform")
      -- Format on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function(args)
          conform.format({ bufnr = args.buf, timeout_ms = 500, lsp_fallback = true })
        end,
      })

      -- Comments
      require('Comment').setup({
        padding = true,
        sticky = true,
        ignore = "^$", -- ignora linee vuote
        toggler = {
          line = "gl",
          block = "gb"
        },
        opleader = {
          line = "gl",
          block = "gb"
        }
      })

      -- Autopairs
      require('nvim-autopairs').setup({
        check_ts = true,
        disable_filetype = {"TelescopePrompt"},
        enable_check_bracket_line = true,
      })
    '';
  };
}
