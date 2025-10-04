# modules/home/shell-config.nix
{config, ...}: {

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
      '';

      initContent = ''
        export EDITOR=nvim
        # Tool integrations
        eval "$(starship init zsh)"
        eval "$(direnv hook zsh)"

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
        export EDITOR=nvim
        # Tool integrations
        eval "$(starship init bash)"
        eval "$(direnv hook bash)"

        # FZF integration
        if [ -f "$HOME/.fzf.bash" ]; then
         source "$HOME/.fzf.bash"
        fi
      '';
    };
  };
}
