{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local act = wezterm.action

      return {
        font = wezterm.font('JetBrains Mono'),
        font_size = 12,
        color_scheme = 'Dracula',
        window_background_opacity = 0.9,
        unix_domains = {
          {
            name = 'unix',
          },
        },
        window_close_confirmation = 'NeverPrompt',
        window_decorations = "RESIZE",

        -- Override all default shortcuts
        disable_default_key_bindings = true,

        -- Custom shortcut definitions
        keys = {
          -- Shortcut to open a new tab (Ctrl + T)
          { key = 't', mods = 'CTRL', action = act.SpawnTab 'DefaultDomain' },

          -- Shortcut to close the current tab (Ctrl + W)
          { key = 'w', mods = 'CTRL', action = act.CloseCurrentTab{ confirm = false } },

          -- Other necessary shortcuts
          { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
          { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
          { key = 'f', mods = 'CTRL|SHIFT', action = act.ToggleFullScreen },
        },
      }
    '';
  };

  # Ensure the configuration directory exists
  home.file.".config/wezterm/.keep".text = "";
}
