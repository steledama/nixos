# nixos/modules/home/wezterm.nix
{ pkgs, ... }: {
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = {}

      -- Configurazione di base
      config.font = wezterm.font 'JetBrainsMono Nerd Font'
      config.font_size = 13.0
      config.window_padding = {
        left = 8,
        right = 8,
        top = 8,
        bottom = 8,
      }
      
      -- Opacità e finestra
      config.window_background_opacity = 1.0
      config.hide_tab_bar_if_only_one_tab = true
      
      -- Colori OneDark (versione semplificata)
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
      
      -- Shell predefinita
      config.default_prog = { '${pkgs.zsh}/bin/zsh', '-l' }
      
      -- Scorciatoie di base per multiplexing
      config.keys = {
        -- Clipboard
        { key = 'c', mods = 'CTRL', action = wezterm.action.CopyTo('Clipboard') },
        { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom('Clipboard') },
        
        -- Multiplexing base
        { key = '\\', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
        { key = '-', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
        { key = 'x', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane { confirm = true } },
        
        -- Navigazione pannelli
        { key = 'LeftArrow', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection('Left') },
        { key = 'RightArrow', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection('Right') },
        { key = 'UpArrow', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection('Up') },
        { key = 'DownArrow', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection('Down') },
        
        -- Tab management
        { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
        { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = true } },
        { key = 'Tab', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
        { key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
        
        -- Zoom pannello
        { key = 'z', mods = 'CTRL|SHIFT', action = wezterm.action.TogglePaneZoomState },
      }
      
      return config
    '';
  };
}

