# modules/home/tmux.nix
# Minimal base configuration with default shortcuts
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
    
    # Using the default Ctrl+b prefix (commented for clarity)
    # prefix = "C-b";
    
    # Essential configuration
    extraConfig = ''
      # True-color support
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      
      # Base settings
      set -g base-index 1         # Start window numbering at 1
      set -g pane-base-index 1    # Start pane numbering at 1
      
      # Simple theme
      set -g status-style bg=default,fg=white
      set -g status-left " #S "
      set -g status-right " %H:%M "
      set -g window-status-current-format " #I:#W "
      set -g window-status-format " #I:#W "
    '';
  };
}
