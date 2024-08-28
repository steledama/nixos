{ pkgs, config, lib, ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      # Dimensioni della finestra
      remember_window_size = "yes";
      # initial_window_width e initial_window_height
      # initial_window_width = "110c";
      # initial_window_height = "36c";

      # Padding
      window_padding_width = 15;

      # Opacità
      background_opacity = "0.9";

      # Cursore
      cursor_shape = "beam";
      cursor_blink_interval = 1;

      # Font
      font_family = "JetBrainsMono NFM";
      bold_font = "JetBrainsMono NFM";
      italic_font = "JetBrainsMono NFM";
      bold_italic_font = "JetBrainsMono NFM";
      font_size = 14;

      # Colori
      bold_is_bright = "yes";
    };

    # Altre opzioni specifiche di Kitty
    extraConfig = ''
      enable_audio_bell no
      update_check_interval 0
    '';
  };
}
