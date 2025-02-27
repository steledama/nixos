{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font Mono";
      size = 13;
    };
    settings = {
      # Term
      term = "xterm-256color";

      # Allow running kitty command from nvim
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/mykitty";

      # Window
      # hide_window_decorations = "titlebar-only"; hide window
      window_margin_width = "0 3 0 3";

      # Transparency
      background_blur = 12;
      text_composition_strategy = "1.7 30";
      cursor_beam_thickness = 1.0;
      clipboard_control = "write-clipboard write-primary";

      # Theme Overrides
      background = "#282c35";
      foreground = "#abb2bf";
      active_border_color = "#00ff00";

      # Background image
      background_image = "~/code/dotfiles/img/bg-monterey.png";
      background_image_layout = "scaled";
      background_tint = 0.85;
      background_image_linear = "yes";

      # Font configuration
      bold_font = "JetBrainsMono Nerd Font Mono Extra Bold";
      bold_italic_font = "JetBrainsMono Nerd Font Mono Extra Bold Italic";
    };

    extraConfig = ''
      # Symbols Nerd Font complete symbol_map
      # "Nerd Fonts - Pomicons"
      symbol_map  U+E000-U+E00D Symbols Nerd Font

      # "Nerd Fonts - Powerline"
      symbol_map U+e0a0-U+e0a2,U+e0b0-U+e0b3 Symbols Nerd Font

      # "Nerd Fonts - Powerline Extra"
      symbol_map U+e0a3-U+e0a3,U+e0b4-U+e0c8,U+e0cc-U+e0d2,U+e0d4-U+e0d4 Symbols Nerd Font

      # "Nerd Fonts - Symbols original"
      symbol_map U+e5fa-U+e62b Symbols Nerd Font

      # "Nerd Fonts - Devicons"
      symbol_map U+e700-U+e7c5 Symbols Nerd Font

      # "Nerd Fonts - Font awesome"
      symbol_map U+f000-U+f2e0 Symbols Nerd Font

      # "Nerd Fonts - Font awesome extension"
      symbol_map U+e200-U+e2a9 Symbols Nerd Font

      # "Nerd Fonts - Octicons"
      symbol_map U+f400-U+f4a8,U+2665-U+2665,U+26A1-U+26A1,U+f27c-U+f27c Symbols Nerd Font

      # "Nerd Fonts - Font Linux"
      symbol_map U+F300-U+F313 Symbols Nerd Font

      #  Nerd Fonts - Font Power Symbols"
      symbol_map U+23fb-U+23fe,U+2b58-U+2b58 Symbols Nerd Font

      #  "Nerd Fonts - Material Design Icons"
      symbol_map U+f500-U+fd46 Symbols Nerd Font

      # "Nerd Fonts - Weather Icons"
      symbol_map U+e300-U+e3eb Symbols Nerd Font

      # Misc Code Point Fixes
      symbol_map U+21B5,U+25B8,U+2605,U+2630,U+2632,U+2714,U+E0A3,U+E615,U+E62B Symbols Nerd Font
    '';
  };

  # Copia i file di tema e configurazione
  xdg.configFile = {
    "kitty/onedark.conf".source = ./kitty/onedark.conf;
    "kitty/custom.conf".source = ./kitty/custom.conf;
  };
}
