# nixos/module/home/neovim.nix
{ ... }: {
  programs.nixvim = {
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
            spelling = { enabled = true; };
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
        extensions.fzf-native.enable = true;
      };

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
          followCurrentFile.enabled = true;
          filteredItems = {
            hideDotfiles = false;
            hideByName = [ "node_modules" ".git" ];
          };
        };
      };

      # Simplified treesitter section
      treesitter = {
        enable = true;
        nixGrammars = true; # Install all grammars from nixpkgs
      };

      lsp = {
        enable = true;
        servers = {
          # Fixed server names
          ts_ls.enable = true;
          pyright.enable = true;
          nil_ls = {
            enable = true;
            settings.formatting.command = [ "nixpkgs-fmt" ];
          };
          lua_ls = {
            enable = true;
            settings.Lua = {
              completion.callSnippet = "Replace";
              diagnostics.globals = [ "vim" ];
            };
          };
        };
      };

      cmp = {
        enable = true;
        settings = {
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
            timeout_ms = 500;
            lsp_fallback = true;
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
        settings.options = {
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

      comment.enable = true;
      nvim-autopairs.enable = true;
    };

    keymaps = [
      # Esc with no highlight from internal search
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
      }

      # Neo-tree toggle
      {
        mode = "n";
        key = "\\";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Toggle file explorer";
      }

      # Telescope
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

      # Arrows keys windows navigation
      {
        mode = "n";
        key = "<C-Left>";
        action = "<C-w><C-h>";
        options.desc = "Move focus to the left window";
      }
      {
        mode = "n";
        key = "<C-Right>";
        action = "<C-w><C-l>";
        options.desc = "Move focus to the right window";
      }
      {
        mode = "n";
        key = "<C-Down>";
        action = "<C-w><C-j>";
        options.desc = "Move focus to the lower window";
      }
      {
        mode = "n";
        key = "<C-Up>";
        action = "<C-w><C-k>";
        options.desc = "Move focus to the upper window";
      }

      # Buffer navigation with bufferline
      {
        mode = "n";
        key = "<leader><Tab>";
        action = "<cmd>BufferLineCycleNext<CR>";
        options.desc = "Next buffer";
      }
      {
        mode = "n";
        key = "<leader><S-Tab>";
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
        action.__raw = ''
          function()
            require("conform").format({
              async = true,
              lsp_fallback = true,
              timeout_ms = 500,
            })
          end
        '';
        options.desc = "Format buffer";
      }
    ];

    colorschemes.tokyonight = {
      enable = true;
      settings.style = "night";
    };

    autoGroups = {
      kickstart_highlight_yank = {
        clear = true;
      };
    };

    autoCmd = [
      {
        event = "TextYankPost";
        group = "kickstart_highlight_yank";
        callback.__raw = ''
          function()
            vim.highlight.on_yank()
          end
        '';
      }
    ];

    extraConfigLua = ''
      -- Comments
      require('Comment').setup({
        padding = true,
        sticky = true,
        ignore = "^$", -- ignora linee vuote
        toggler = {
          line = "gll",
          block = "gbb"
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
