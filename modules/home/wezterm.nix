# nixos/modules/home/wezterm.nix
{...}: {
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    extraConfig = ''
      local wezterm = require 'wezterm'

      local config = {}

      -- Basic config
      config.font = wezterm.font('JetBrainsMono Nerd Font')
      config.font_size = 13.0
      config.window_padding = {
        left = 8,
        right = 8,
        top = 8,
        bottom = 8
      }

      -- Opacity and window
      config.window_background_opacity = 0.9
      config.hide_tab_bar_if_only_one_tab = true

      -- Shortcuts
      config.keys = {
        {
          key = 't',
          mods = 'CTRL',
          action = wezterm.action.SpawnTab('CurrentPaneDomain')
        },

        {
          key = 'w',
          mods = 'CTRL',
          action = wezterm.action.CloseCurrentTab { confirm = true }
        },

        {
          key = 'Tab',
          mods = 'CTRL',
          action = wezterm.action.ActivateTabRelative(1)
        },

        {
          key = 'Tab',
          mods = 'CTRL|SHIFT',
          action = wezterm.action.ActivateTabRelative(-1)
        },

        { key = '1', mods = 'CTRL', action = wezterm.action.ActivateTab(0) },
        { key = '2', mods = 'CTRL', action = wezterm.action.ActivateTab(1) },
        { key = '3', mods = 'CTRL', action = wezterm.action.ActivateTab(2) },
        { key = '4', mods = 'CTRL', action = wezterm.action.ActivateTab(3) },
        { key = '5', mods = 'CTRL', action = wezterm.action.ActivateTab(4) },
        { key = '6', mods = 'CTRL', action = wezterm.action.ActivateTab(5) },
        { key = '7', mods = 'CTRL', action = wezterm.action.ActivateTab(6) },
        { key = '8', mods = 'CTRL', action = wezterm.action.ActivateTab(7) },
        { key = '9', mods = 'CTRL', action = wezterm.action.ActivateTab(8) },
        { key = '0', mods = 'CTRL', action = wezterm.action.ActivateTab(9) },
      }

      -- Use X11, not wayland
      config.enable_wayland = false

      return config
    '';
  };
}
