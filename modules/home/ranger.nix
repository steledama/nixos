{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Installa ranger e le sue dipendenze
  home.packages = with pkgs; [
    ranger
    file # Per riconoscere i tipi di file
    libcaca # Per visualizzare le immagini ASCII
    highlight # Per evidenziare la sintassi
    atool # Per l'estrazione di archivi
    mediainfo # Per informazioni sui file multimediali
    poppler_utils # Per PDF
    ffmpegthumbnailer # Per le miniature video
  ];

  # Configura i file di ranger
  xdg.configFile = {
    "ranger/rc.conf".source = ./ranger/rc.conf;
    "ranger/scope.sh" = {
      source = ./ranger/scope.sh;
      executable = true;
    };
    "ranger/commands.py".text = ''
      # Aggiungi qui i tuoi comandi personalizzati se necessario
    '';
  };
}
