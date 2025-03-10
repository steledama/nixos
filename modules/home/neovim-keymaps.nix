# nixos/modules/home/neovim-keymaps.nix
{ ... }: {
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
      options = {
        desc = "Toggle file explorer";
      };
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

    # Navigazione buffers con bufferline
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
      options = {
        desc = "Format buffer";
      };
    }
  ];
}
