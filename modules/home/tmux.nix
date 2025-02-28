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

    # Basic settings
    terminal = "screen-256color";
    escapeTime = 0;
    historyLimit = 10000;
    mouse = true;
    keyMode = "vi";

    # Essential configuration
    extraConfig = ''
      # Command prompt
      unbind :
      bind . command-prompt

      # Split horizontally
      unbind %
      bind - split-window -v -c "#{pane_current_path}"

      # Split vertically
      unbind %
      bind \\ split-window -h -c "#{pane_current_path}"

      # New window
      bind t new-window -c "#{pane_current_path}"

      # Close current
      bind w kill-window

      # Switch to next window
      bind Tab next-window

      # Kill pane
      bind DC kill-pane

      # True-color support
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"

      # Base settings
      set -g base-index 1         # Start window numbering at 1
      set -g pane-base-index 1    # Start pane numbering at 1
      set -g set-clipboard on     # Use system clipboard when possible

      # Enable vi mode for copy operations
      set-window-option -g mode-keys vi

      # Copy mode customization for smoother integration with system clipboard
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"

      # Simple theme
      set -g status-style bg=default,fg=white
      set -g status-left " #S "
      set -g status-right " %H:%M "
      set -g window-status-current-format " #I:#W "
      set -g window-status-format " #I:#W "
    '';
  };
}
