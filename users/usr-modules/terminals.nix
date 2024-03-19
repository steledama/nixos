{ pkgs, config, lib, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding.x = 15;
        padding.y = 15;
        # decorations = "none";
        startup_mode = "Windowed";
        dynamic_title = true;
        opacity = 0.9;
      };
      cursor = {
        style = {
          shape = "Beam";
          blinking = "On";
        };
      };
      live_config_reload = true;
      font = {
        normal.family = "JetBrainsMono NFM";
        bold.family = "JetBrainsMono NFM";
        italic.family = "JetBrainsMono NFM";
        bold_italic.family = "JetBrainsMono NFM";
        size = 14;
      };
      colors.draw_bold_text_with_bright_colors = true;
    };
  };

  # Configure Kitty
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    font.name = "JetBrainsMono Nerd Font";
    font.size = 16;
    settings = {
      scrollback_lines = 2000;
      wheel_scroll_min_lines = 1;
      window_padding_width = 4;
      confirm_os_window_close = 0;
      background_opacity = "0.85";
    };
    extraConfig = ''
      tab_bar_style fade
      tab_fade 1
      active_tab_font_style   bold
      inactive_tab_font_style bold
    '';
  };

  # Configure wezterm
  programs.wezterm = {
    enable = true;
    package = pkgs.wezterm;
    enableBashIntegration = true;
    extraConfig = ''
    -- Your lua code / config here
local mylib = require 'mylib';
return {
  usemylib = mylib.do_fun();
  font = wezterm.font("JetBrains Mono"),
  font_size = 16.0,
  color_scheme = "Tomorrow Night",
  hide_tab_bar_if_only_one_tab = true,
}
    '';
  };


}


