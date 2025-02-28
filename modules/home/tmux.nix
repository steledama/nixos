# modules/home/tmux.nix
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
    historyLimit = 10000;
    mouse = true;
    keyMode = "vi";
    prefix = "C-Space";

    # Configurazione completa incluso il tema
    extraConfig = ''
      # Supporto true-color
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"

      # Impostazioni base
      set -g set-clipboard on     # Usa la clipboard di sistema
      set -g base-index 1         # Inizia la numerazione delle finestre da 1
      set -g pane-base-index 1    # Inizia la numerazione dei pannelli da 1
      set -g renumber-windows on  # Rinumera le finestre quando una viene chiusa

      # Split horizontally in CWD con \
      unbind %
      bind \\ split-window -h -c "#{pane_current_path}"

      # Split vertically in CWD con -
      unbind \"
      bind - split-window -v -c "#{pane_current_path}"

      # Nuova finestra nello stesso path
      bind c new-window -c "#{pane_current_path}"

      # Usa i tasti freccia vim per ridimensionare
      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r h resize-pane -L 5

      # Massimizza pannello con m
      bind -r m resize-pane -Z

      # Abilita modalità vi
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi 'v' send -X begin-selection 
      bind -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel "pbcopy"

      # Impostazioni tema minimalista
      set -g status-style bg=default,fg=white
      set -g status-left "#[fg=green,bold] #S "
      set -g status-right "#[fg=white] %H:%M "
      set -g window-status-current-format "#[fg=cyan,bold] #I:#W "
      set -g window-status-format " #I:#W "
      set -g pane-border-style "fg=colour240"
      set -g pane-active-border-style "fg=cyan"
    '';

    # Plugin essenziale per la navigazione Neovim-Tmux
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
    ];
  };
}
