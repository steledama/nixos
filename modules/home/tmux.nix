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
    customPaneNavigationAndResize = true;
    prefix = "C-Space";
    extraConfig = ''
      # Enable 256-color and true-color (24-bit) support in tmux
      set -g default-terminal "screen-256color" # Set terminal type for 256-color support
      set -ga terminal-overrides ",*256col*:Tc" # Override to enable true-color for compatible terminals

      # General
      set -g set-clipboard on         # Use system clipboard
      set -g detach-on-destroy off    # Don't exit from tmux when closing a session
      set -g escape-time 0            # Remove delay for exiting insert mode with ESC in Neovim
      set -g history-limit 1000000    # Increase history size (from 2,000)
      set -g mouse on                 # Enable mouse support
      set -g status-interval 3        # Update the status bar every 3 seconds (default: 15 seconds)
      set -g allow-passthrough on     # Allow programs in the pane to bypass tmux (e.g. for image preview)

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

      # Enable vi mode to allow us to use vim keys to move around in copy mode (Prefix + [ places us in copy mode)
      set-window-option -g mode-keys vi

      # Start selecting text with "v"
      bind-key -T copy-mode-vi 'v' send -X begin-selection 

      # Copy text with "y"
      bind -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel "pbcopy"

      # Start windows and panes at 1, not 0
      set -g base-index 1
      set -g pane-base-index 1
      set -g renumber-windows on # Automatically renumber windows when one is closed

      # Status bar information (aggiunto al posto del plugin cpu-mem-monitor)
      set -g status-right "#[fg=cyan] CPU: #(top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}')% | MEM: #(free -m | awk 'NR==2{printf \"%.1f%%\", $3*100/$2}') "
    '';
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator # Enable navigating between nvim and tmux
      resurrect # Persist tmux sessions after computer restart
      continuum # Automatically saves sessions every 15 minutes
      # Rimosso il plugin cpu-mem-monitor che non è disponibile nel pkgs.tmuxPlugins
    ];
  };

  # Crea directory per i file di tema
  home.file = {
    ".config/tmux/onedark-theme.conf".text = ''
      bg="#2c323c"
      default_fg="#abb2bf"
      session_fg="#98c379"
      selection_bg="#98c379"
      selection_fg="#282c34"
      active_pane_border="#abb2bf"
      active_window_fg="#61afef"

      set -g status-position bottom
      set -g status-left "#[fg=''${session_fg},bold,bg=''${bg}] #S"
      set -g status-right "#[fg=''${default_fg},bg=''${bg}] 󰃮 %Y-%m-%d 󱑒 %H:%M"
      set -g status-justify centre
      set -g status-left-length 200  # default: 10
      set -g status-right-length 200 # default: 10
      set-option -g status-style bg=''${bg}
      set -g window-status-current-format "#[fg=''${active_window_fg},bg=default]  #I:#W"
      set -g window-status-format "#[fg=''${default_fg},bg=default] #I:#W"
      set -g window-status-last-style "fg=''${default_fg},bg=default"
      set -g message-command-style bg=default,fg=''${default_fg}
      set -g message-style bg=default,fg=''${default_fg}
      set -g mode-style bg=''${selection_bg},fg=''${selection_fg}
      set -g pane-active-border-style "fg=''${active_pane_border},bg=default"
      set -g pane-border-style 'fg=brightblack,bg=default'
    '';

    ".config/tmux/nord-theme.conf".text = ''
      bg="#3B4252"
      default_fg="#D8DEE9" 
      session_fg="#A3BE8C"
      session_selection_fg="#3B4252"
      session_selection_bg="#81A1C1"
      active_window_fg="#88C0D0"
      active_pane_border="#abb2bf"

      set -g status-left-length 200   # default: 10
      set -g status-right-length 200  # default: 10
      set -g status-left "#[fg=''${session_fg},bold,bg=''${bg}]  #S"
      set -g status-right " CPU: #(top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}')% | MEM: #(free -m | awk 'NR==2{printf \"%.1f%%\", $3*100/$2}') "
      set -g status-justify centre
      set -g status-style "bg=''${bg}"
      set -g window-status-format "#[fg=''${default_fg},bg=default] #I:#W"
      set -g window-status-current-format "#[fg=''${active_window_fg},bg=default]  #I:#W"
      set -g window-status-last-style "fg=''${default_fg},bg=default"
      set -g message-command-style "bg=default,fg=''${default_fg}"
      set -g message-style "bg=default,fg=''${default_fg}"
      set -g mode-style "bg=''${session_selection_bg},fg=''${session_selection_fg}"
      set -g pane-active-border-style "fg=''${active_pane_border},bg=default"
      set -g pane-border-style "fg=brightblack,bg=default"
    '';
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
