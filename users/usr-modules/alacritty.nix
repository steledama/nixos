{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        dimensions = {
          columns = 110;
          lines = 36;
        };
        padding = {
          x = 15;
          y = 15;
        };
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
}
