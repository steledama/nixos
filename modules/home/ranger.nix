# nixos/modules/home/ranger.nix

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Installa ranger e le sue dipendenze essenziali
  home.packages = with pkgs; [
    ranger
    file # Per riconoscere i tipi di file
    highlight # Per evidenziare la sintassi
    atool # Per l'estrazione di archivi
    mediainfo # Per informazioni sui file multimediali
    poppler_utils # Per PDF
  ];

  # Configurazione direttamente inline senza file esterni
  programs.ranger = {
    enable = true;

    # Configurazioni principali equivalenti a rc.conf
    settings = {
      show_hidden = true;
      preview_images = true;
      vcs_aware = true;
      draw_borders = true;
    };

    # Configurazione per l'anteprima delle immagini
    previewer = {
      enable = true;
      preview_script_path = "${pkgs.ranger}/share/ranger/data/scope.sh";
    };

    # Keybindings personalizzati (equivalenti a quelli in rc.conf)
    keybindings = {
      "gh" = "cd ~";
      "g/" = "cd /";
      "gd" = "cd ~/Documents";
      "gD" = "cd ~/Downloads";
      "DD" = "shell rm -rf %s";
      "X" = "shell extract %f";
      "Z" = "shell tar -cvzf %f.tar.gz %s";
    };
  };

  # Configurazione aggiuntiva se necessaria
  xdg.configFile = {
    # Comandi personalizzati per ranger
    "ranger/commands.py".text = ''
      # Comandi personalizzati per ranger
      from ranger.api.commands import Command

      class extract(Command):
          """:extract <paths>
          
          Extract archives using atool
          """
          def execute(self):
              import os
              from ranger.ext.shell_escape import shell_escape as esc
              
              if not self.arg(1):
                  self.fm.notify("Specificare un file da estrarre", bad=True)
                  return
                  
              files = [f.path for f in self.fm.thistab.get_selection()]
              if not files:
                  files = [self.fm.thisfile.path]
                  
              self.fm.execute_command(["atool", "--extract"] + files)
    '';
  };
}
