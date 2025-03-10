# nixos/modules/home/wezterm.nix
{ ... }: {
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    extraConfig = ''
            local wezterm = require 'wezterm'
            local config = {}

            -- Basic config
            config.font = wezterm.font 'JetBrainsMono Nerd Font'
            config.font_size = 13.0
            config.window_padding = {
              left = 8,
              right = 8,
              top = 8,
              bottom = 8,
            }

            -- Opacity and window
            config.window_background_opacity = 1.0
            config.hide_tab_bar_if_only_one_tab = true

            -- OneDark theme semplified
            config.colors = {
              foreground = '#abb2bf',
              background = '#282c34',
              cursor_fg = '#282c34',
              cursor_bg = '#abb2bf',

              ansi = {
                '#282c34', -- black
                '#e06c75', -- red
                '#98c379', -- green
                '#e5c07b', -- yellow
                '#61afef', -- blue
                '#c678dd', -- magenta
                '#56b6c2', -- cyan
                '#abb2bf', -- white
              },

              brights = {
                '#545862', -- bright black
                '#e06c75', -- bright red
                '#98c379', -- bright green
                '#e5c07b', -- bright yellow
                '#61afef', -- bright blue
                '#c678dd', -- bright magenta
                '#56b6c2', -- bright cyan
                '#c8ccd4', -- bright white
              },
            }

            -- Keymaps
            config.keys = {
      -- Clipboard: CTRL+C copia in modalità selezione, altrimenti invia il segnale di interruzione
      { key = 'c', mods = 'CTRL', 
        action = wezterm.action_callback(function(window, pane)
          local has_selection = window:get_selection_text_for_pane(pane) ~= ""
          if has_selection then
            window:perform_action(wezterm.action.CopyTo('Clipboard'), pane)
          else
            window:perform_action(wezterm.action.SendKey{ key = 'c', mods = 'CTRL' }, pane)
          end
        end)
      },

              -- Multiplexing
              { key = '|', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
              { key = '_', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },

              -- Navigation panes
              { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection('Left') },
              { key = 'RightArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection('Right') },
              { key = 'UpArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection('Up') },
              { key = 'DownArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection('Down') },
              -- Close current pane
              { key = 'Delete', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane { confirm = true } },

              -- Tab management
              { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
              { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = true } },
              { key = 'Tab', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
              { key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },

              -- Tab navigation by number for Italian keyboard layout
              { key = '!', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTab(0) },  -- Ctrl+Shift+1
              { key = '"', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTab(1) },  -- Ctrl+Shift+2
              { key = '£', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTab(2) },  -- Ctrl+Shift+3
              { key = '$', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTab(3) },  -- Ctrl+Shift+4
              { key = '%', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTab(4) },  -- Ctrl+Shift+5
              { key = '&', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTab(5) },  -- Ctrl+Shift+6
              { key = '/', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTab(6) },  -- Ctrl+Shift+7
              { key = '(', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTab(7) },  -- Ctrl+Shift+8
              { key = ')', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTab(8) },  -- Ctrl+Shift+9
              { key = '=', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTab(9) },  -- Ctrl+Shift+0
              -- Go to last tab
              { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTab(-1)},
            }

            -- X11 not wayland
            config.enable_wayland = false

            return config
    '';
  };
}
