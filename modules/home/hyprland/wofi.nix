# modules/home/hyprland/wofi.nix
{colors}: {
  # Configurazione di Wofi
  config = ''
    width=700
    height=900
    prompt=Cerca
    insensitive=true
    hide_scroll=true
    location=center
    lines=15
    always_parse_args=true
    show_all=true
    gtk_dark=true
  '';

  # Stile di Wofi
  style = ''
    window {
      opacity: 0.90;
      border-radius: 10px;
      background-color: ${colors.background};
      color: ${colors.foreground};
      font-family: 'JetBrainsMono Nerd Font';
    }
    #outer-box {
      margin: 10px;
    }
    #inner-box {
      background-color: transparent;
      color: ${colors.foreground};
    }
    #input {
      margin: 5px;
      border-radius: 6px;
      background-color: rgba(61, 66, 77, 0.8);
      border: 1px solid ${colors.blue};
      color: ${colors.foreground};
      font-size: 110%;
    }
    #scroll {
      background-color: transparent;
      margin: 0;
      padding: 0;
    }
    #text {
      color: ${colors.foreground};
      margin: 2px;
      padding: 2px 0; /* Aggiungiamo padding verticale invece di line-height */
      font-size: 105%;  /* Dimensione font aumentata */
    }
    #entry {
      border-radius: 5px;
      padding: 3px;
      margin: 1px 0;
      background-color: transparent;
      min-height: 0;
    }
    #entry:selected {
      background-color: rgba(97, 175, 239, 0.2);
    }
    * {
      color: ${colors.foreground};
    }
  '';
}
