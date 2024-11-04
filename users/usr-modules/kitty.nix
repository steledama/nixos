{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    
    # Font settings
    font = {
      name = "JetBrainsMono NFM";
      size = 14;
    };
    
    # Window settings
    settings = {
      # Window appearance
      remember_window_size = "no";
      initial_window_width = "110c";
      initial_window_height = "36c";
      window_padding_width = 15;
      background_opacity = "0.9";
      dynamic_background_opacity = "yes";
      
      # Cursor customization
      cursor_shape = "beam";
      cursor_blink_interval = "0.5";
      
      # Tab bar
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_min_tabs = 1;
      
      # Bell
      enable_audio_bell = "no";
      visual_bell_duration = "0.0";
      window_alert_on_bell = "yes";
      
      # Terminal bell
      bell_on_tab = "🔔 ";
      
      # Scrollback
      scrollback_lines = 10000;
      
      # URL handling
      url_style = "curly";
      open_url_with = "default";
      url_prefixes = "http https file ftp";
      detect_urls = "yes";
      
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";
      
      # Window layout
      enabled_layouts = "tall,stack,fat,grid,splits";
      window_resize_step_cells = 2;
      window_resize_step_lines = 2;
      
      # Shell integration
      shell_integration = "enabled";
      
      # Mouse
      mouse_hide_wait = 3;
      copy_on_select = "no";
      strip_trailing_spaces = "smart";
      
      # Advanced
      term = "xterm-kitty";
      update_check_interval = 0;

      # Catppuccin Mocha Theme Colors
      foreground = "#CDD6F4";
      background = "#1E1E2E";
      selection_foreground = "#1E1E2E";
      selection_background = "#F5E0DC";
      cursor = "#F5E0DC";
      cursor_text_color = "#1E1E2E";
      
      # Terminal colors
      color0 = "#45475A";
      color8 = "#585B70";
      color1 = "#F38BA8";
      color9 = "#F38BA8";
      color2 = "#A6E3A1";
      color10 = "#A6E3A1";
      color3 = "#F9E2AF";
      color11 = "#F9E2AF";
      color4 = "#89B4FA";
      color12 = "#89B4FA";
      color5 = "#F5C2E7";
      color13 = "#F5C2E7";
      color6 = "#94E2D5";
      color14 = "#94E2D5";
      color7 = "#BAC2DE";
      color15 = "#A6ADC8";
      
      # Tab bar colors
      active_tab_foreground = "#1E1E2E";
      active_tab_background = "#CBA6F7";
      inactive_tab_foreground = "#CDD6F4";
      inactive_tab_background = "#181825";
      tab_bar_background = "#11111B";
    };
    
    # Keyboard shortcuts
    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+s" = "paste_from_selection";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_tab";
      "ctrl+shift+l" = "next_tab";
      "ctrl+shift+h" = "previous_tab";
      "ctrl+shift+plus" = "change_font_size all +2.0";
      "ctrl+shift+minus" = "change_font_size all -2.0";
      "ctrl+shift+backspace" = "change_font_size all 0";
    };
  };
  
  # Additional packages
  home.packages = with pkgs; [
    kitty-themes
    imagemagick
  ];
}
