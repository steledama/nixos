{ pkgs, config, lib, ... }:

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      
      return {
        font = wezterm.font('JetBrains Mono'),
        font_size = 14,
        color_scheme = 'Dracula',
        window_background_opacity = 0.9,
        window_padding = {
          left = 15,
          right = 15,
          top = 15,
          bottom = 15,
        },
        initial_cols = 120,
        initial_rows = 38,
        unix_domains = {
          {
            name = 'unix',
          },
        },
        -- Abilita il salvataggio della posizione e dimensione della finestra
        save_window_position = true,
        window_close_confirmation = 'NeverPrompt',
      }
    '';
  };
}
