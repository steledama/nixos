# modules/home/shell-config.nix
{ config
, pkgs
, ...
}: {
  # Common shell aliases for both bash and zsh
  home.shellAliases = {
    # Navigation
    ".." = "cd ..";
    "..." = "cd ../..";

    # System utilities
    ll = "ls -l";
    la = "ls -a";
    lal = "ls -al";
    c = "clear";
    e = "exit";

    # NixOS
    nrb = "sudo nixos-rebuild switch --flake .";
    nup = "nix flake update";
    ngc = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot && sudo nvim /boot/loader/loader.conf";

    # Editor
    v = "nvim";
    sv = "sudo nvim";

    # Git
    g = "git";
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git pull";

    # Tmux
    ta = "tmux attach -t";
    tl = "tmux list-sessions";
    tn = "tmux new -s";

    # Modern utilities
    ls = "eza --icons=always";
    cat = "bat";
    find = "fd";
    grep = "rg";
  };

  # Shell tools configurations
  programs = {
    # Starship prompt
    starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      settings = {
        add_newline = false;
        command_timeout = 1000;

        character = {
          success_symbol = "[➜](green)";
          error_symbol = "[✗](red)";
          vicmd_symbol = "[V](green)";
        };

        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
        };

        # Git configuration
        git_branch = {
          format = "[$symbol$branch]($style) ";
          symbol = "🌿 ";
        };

        git_status = {
          format = "([●](red)[$all_status$ahead_behind]($style))";
          conflicted = "≠";
          ahead = "⇡$count";
          behind = "⇣$count";
          diverged = "⇕⇡$ahead_count⇣$behind_count";
          untracked = "?$count";
          stashed = "\\$$count";
          modified = "!$count";
          staged = "+$count";
          renamed = "»$count";
          deleted = "✘$count";
        };
      };
    };

    # zoxide - smarter cd
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      options = [
        "--cmd cd" # Replace cd command
      ];
      enableFishIntegration = true;
    };

    # tmux configuration
    tmux = {
      enable = true;
      terminal = "screen-256color";
      escapeTime = 0;
      historyLimit = 10000;
      mouse = true;
      keyMode = "vi";

      # plugins
      plugins = with pkgs.tmuxPlugins; [
        resurrect # Saves and restores tmux sessions
        continuum # Automatic saving of tmux environment
        # vim-tmux-navigator # Seamless navigation between tmux panes and vim splits
      ];

      # extra
      extraConfig = ''
                        # Prefix from C-b to C-a
                        unbind C-b
                        set -g prefix C-a
                        bind C-a send-prefix
                	# Command prompt
                        unbind :
                        bind . command-prompt
        
                	# Session
                	# bind C-s to save session and Prefix C-r to restore
                	# bind s to show the sessions

                        # Window
                        bind t new-window -c "#{pane_current_path}"
                        bind w kill-window
                        bind Tab next-window
                        bind S-Tab previous-window
                	# bind , to rename a window
        
                	# Pane
        		# Split horizontally
                        unbind %
                        bind - split-window -v -c "#{pane_current_path}"
                	# Split vertically
                        unbind %
                        bind \\ split-window -h -c "#{pane_current_path}"
                        bind DC kill-pane

                	# Vi mode for copy operations
                	set-window-option -g mode-keys vi
                        bind -T copy-mode-vi v send-keys -X begin-selection
                        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"

                	# True-color support
                        set -g default-terminal "screen-256color"
                        set -ga terminal-overrides ",*256col*:Tc"

                	# Base settings
                        set -g base-index 1
                        set -g pane-base-index 1
                        set -g set-clipboard on

                	# Status bar styling
                        set -g status-position top
                        set -g status-style bg="#282c34",fg="#abb2bf"
                        set -g window-status-style bg="#282c34",fg="#abb2bf"
                        set -g window-status-current-style bg="#61afef",fg="#282c34",bold

                        # Status bar format
                        set -g status-left " #S "
                        set -g status-right " %H:%M "
                        set -g window-status-format " #I:#W "
                        set -g window-status-current-format " #I:#W "

                	# Pane borders
                        set -g pane-border-style fg="#5c6370"
                        set -g pane-active-border-style fg="#61afef"

                	# Resurrect configuration
                        set -g @resurrect-capture-pane-contents 'on'
                        set -g @resurrect-strategy-nvim 'session'

                	# Continuum configuration
                        set -g @continuum-restore 'on'
                        set -g @continuum-save-interval '10' # Save every 10 minutes
      '';
    };

    # zsh configuration
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      autocd = true;

      # History settings
      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
        ignoreAllDups = true;
        share = true;
      };

      # Completion system setup
      completionInit = ''
        # Initialize completion system
        autoload -Uz compinit && compinit

        # Completion options
        zstyle ':completion:*' menu select
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' verbose true
        zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'

        # Add zoxide tab completion
        compdef _zoxide_z z
      '';

      initExtra = ''
        # Tool integrations
        eval "$(starship init zsh)"
        eval "$(zoxide init zsh --hook pwd)"
        eval "$(direnv hook zsh)"

        # Tmux auto-start
        if [[ -z "$TMUX" && "$TERM" != "screen"* ]]; then
          tmux attach || tmux new
        fi

        # FZF integration
        if [ -f "$HOME/.fzf.zsh" ]; then
          source "$HOME/.fzf.zsh"
        fi
      '';
    };

    # bash configuration
    bash = {
      enable = true;
      enableCompletion = true;

      initExtra = ''
        # Tool integrations
        eval "$(starship init bash)"
        eval "$(zoxide init bash --hook pwd)"
        eval "$(direnv hook bash)"

        # Tmux auto-start
        if [ -z "$TMUX" ] && [ "$TERM" != "screen" ]; then
          tmux attach || tmux new
        fi

        # FZF integration
        if [ -f "$HOME/.fzf.bash" ]; then
          source "$HOME/.fzf.bash"
        fi
      '';
    };
  };
}
