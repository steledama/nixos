# nixos/modules/home/neovim-keymaps.nix
{
  config,
  lib,
  pkgs,
  ...
}: {
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
}
