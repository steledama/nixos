{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "screen-256color";
    escapeTime = 0;
    historyLimit = 1000000;
    mouse = true;
    keyMode = "vi";
    prefix = "C-Space";
    extraConfig = ''
      # Refresh tmux config with r
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf

      # Split horizontally in CWD with \
      unbind %
      bind \\ split-window -h -c "#{pane_current_path}"

      # Split vertically in CWD with -
      unbind \"
      bind - split-window -v -c "#{pane_current_path}"

      # New window in same path
      bind c new-window -c "#{pane_current_path}"

      # Use vim arrow keys to resize
      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r h resize-pane -L 5

      # Use m key to maximize pane
      bind -r m resize-pane -Z

      # Start windows and panes at 1, not 0
      set -g base-index 1
      set -g pane-base-index 1
      set -g renumber-windows on

      # Allow programs in the pane to bypass tmux (e.g. for image preview)
      set -g allow-passthrough on
    '';
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      resurrect
      continuum
      {
        plugin = cpu-mem-monitor;
        extraConfig = "set -g @cpu-mem-monitor-inactivity-color '0'";
      }
    ];
  };

  # Copia i file di tema di tmux
  xdg.configFile = {
    "tmux/onedark-theme.conf".source = ./tmux/onedark-theme.conf;
    "tmux/nord-theme.conf".source = ./tmux/nord-theme.conf;
  };

  # Imposta variabile per il tema
  home.sessionVariables = {
    TMUX_THEME = "onedark"; # o "nord" se preferisci
  };

  # Assicurati che tpm (gestore plugin) sia installato
  home.activation = {
    installTmuxPluginManager = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d ~/.tmux/plugins/tpm ]; then
        $DRY_RUN_CMD mkdir -p ~/.tmux/plugins
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
      fi
    '';
  };
}
