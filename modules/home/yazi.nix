# In home/default.nix o home/<user>/default.nix
{ ... }: {
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true; # se usi zsh

    settings = {
      manager = {
        show_hidden = false;
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
      };
      preview = {
        tab_size = 2;
        max_width = 1000;
        max_height = 1000;
      };
    };
  };
}

