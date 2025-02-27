# nixos/modules/home/ranger.nix

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Configure ranger using Home Manager
  programs.ranger = {
    enable = true;

    # Settings
    settings = {
      show_hidden = true;
      preview_images = true;
      vcs_aware = true;
      draw_borders = true;
    };

    # Correct mapping syntax
    mappings = {
      "gh" = "cd ~";
      "g/" = "cd /";
      "gd" = "cd ~/Documents";
      "gD" = "cd ~/Downloads";
      "DD" = "shell rm -rf %s";
      "X" = "shell extract %f";
      "Z" = "shell tar -cvzf %f.tar.gz %s";
    };
  };

  # Custom commands file
  xdg.configFile = {
    "ranger/commands.py".text = ''
      # Custom commands for ranger
      from ranger.api.commands import Command

      class extract(Command):
          """:extract <paths>
          
          Extract archives using atool
          """
          def execute(self):
              import os
              from ranger.ext.shell_escape import shell_escape as esc
              
              if not self.arg(1):
                  self.fm.notify("Please specify a file to extract", bad=True)
                  return
                  
              files = [f.path for f in self.fm.thistab.get_selection()]
              if not files:
                  files = [self.fm.thisfile.path]
                  
              self.fm.execute_command(["atool", "--extract"] + files)
    '';
  };
}
