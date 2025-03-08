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
    c = "clear";
    e = "exit";

    # Modern utilities
    ll = "eza -l"; # eza as modern ls
    la = "eza -a";
    lal = "eza -al";
    ls = "eza --icons=always";
    cat = "bat";
    find = "fd";
    grep = "rg";

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

    # WezTerm
    w = "wezterm"; # comando base per avviare wezterm
    wm = "wezterm cli list"; # lista le connessioni/sessioni (simile a tl)
    ws = "wezterm cli split-pane"; # divide la finestra corrente

    # Yazi
    y = "yazi";

    # NixOS
    nrb = "sudo nixos-rebuild switch --flake .";
    nup = "nix flake update";
    ngc = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot && sudo nvim /boot/loader/loader.conf";
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
        export EDITOR=nvim
        # Tool integrations
        eval "$(starship init zsh)"
        eval "$(zoxide init zsh --hook pwd)"
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
        eval "$(zoxide init bash --hook pwd)"
        eval "$(direnv hook bash)"
        
        # FZF integration
        if [ -f "$HOME/.fzf.bash" ]; then
         source "$HOME/.fzf.bash"
        fi
      '';
    };
  };
}

