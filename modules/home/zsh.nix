{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.zsh = {
    # specifi user settings
    autocd = true;

    # command history
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 10000;
      share = true;
    };

    # Added aliases
    shellAliases = {
      # System
      shutdown = "sudo shutdown now";
      restart = "sudo reboot";
      suspend = "sudo pm-suspend";
      sleep = "pmset sleepnow";
      c = "clear";
      e = "exit";

      # Git
      g = "git";
      ga = "git add";
      gafzf = "git ls-files -m -o --exclude-standard | grep -v \"__pycache__\" | fzf -m --print0 | xargs -0 -o -t git add";
      grmfzf = "git ls-files -m -o --exclude-standard | fzf -m --print0 | xargs -0 -o -t git rm";
      grfzf = "git diff --name-only | fzf -m --print0 | xargs -0 -o -t git restore";
      grsfzf = "git diff --name-only | fzf -m --print0 | xargs -0 -o -t git restore --staged";
      gf = "git fetch";
      gs = "git status";
      gss = "git status -s";

      # Neovim
      v = "poetry_run_nvim";
      vi = "poetry_run_nvim";

      # Folders
      doc = "$HOME/Documents";
      dow = "$HOME/Downloads";

      # Ranger
      r = ". ranger";

      # Better ls
      ls = "eza --all --icons=always";

      # Lazygit
      lg = "lazygit";
    };

    initExtra = ''
      # Pyenv
      export PYENV_ROOT="$HOME/.pyenv"
      export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init -)" # Initialize pyenv when a new shell spawns

      # Poetry
      export PATH="$HOME/.local/bin:$PATH"
      export PIPENV_VENV_IN_PROJECT=1

      # Homebrew se sei su macOS
      if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        export HOMEBREW_NO_AUTO_UPDATE=1
      fi

      # Funzione poetry_run_nvim
      function poetry_run_nvim() {
        if command -v poetry >/dev/null 2>&1 && [ -f "poetry.lock" ]; then
          poetry run nvim "$@"
        else
          nvim "$@"
        fi
      }

      # quick_commit function per git
      function quick_commit() {
        local branch_name ticket_id commit_message push_flag
        branch_name=$(git branch --show-current)
        ticket_id=$(echo "$branch_name" | awk -F '-' '{print toupper($1"-"$2)}')
        commit_message="$ticket_id: $*"
        push_flag=$1

        if [[ "$push_flag" == "push" ]]; then
          # Remove 'push' from the commit message
          shift # Rimuove il primo argomento
          commit_message="$ticket_id: $*" # Usa i parametri rimanenti
          git commit --no-verify -m "$commit_message" && git push
        else
          git commit --no-verify -m "$commit_message"
        fi
      }
      alias gqc='quick_commit'
      alias gqcp='quick_commit push'

      # FZF setup
      if [ -f "$HOME/.fzf.zsh" ]; then 
        source "$HOME/.fzf.zsh"
        
        export FZF_CTRL_T_OPTS="
          --preview 'bat -n --color=always {}'
          --bind 'ctrl-/:change-preview-window(down|hidden|)'"
        export FZF_DEFAULT_COMMAND='rg --hidden -l ""' # Include hidden files
        
        bindkey "ç" fzf-cd-widget # Fix for ALT+C on Mac
        
        # fd - cd to selected directory
        fd() {
          local dir
          dir=$(find ${"1:-."} -path '*/\.*' -prune \
                          -o -type d -print 2> /dev/null | fzf +m) &&
          cd "$dir"
        }
        
        # fh - search in your command history and execute selected command
        fh() {
          eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
        }
      fi

      # Tmux auto-start
      if which tmux >/dev/null 2>&1; then
        # Check if the current environment is suitable for tmux
        if [[ -z "$TMUX" && \
              $TERM != "screen-256color" && \
              $TERM != "screen" && \
              -z "$VSCODE_INJECTION" && \
              -z "$INSIDE_EMACS" && \
              -z "$EMACS" && \
              -z "$VIM" && \
              -z "$INTELLIJ_ENVIRONMENT_READER" ]]; then
          # Try to attach to the default tmux session, or create a new one if it doesn't exist
          tmux attach -t default || tmux new -s default
        fi
      fi

      # Vi mode
      bindkey -v
      export KEYTIMEOUT=1 # Makes switching modes quicker
      export VI_MODE_SET_CURSOR=true 

      function zle-keymap-select {
        if [[ "''${KEYMAP:-}" == vicmd ]]; then
          echo -ne '\e[2 q' # block cursor
        else
          echo -ne '\e[6 q' # beam cursor
        fi
      }
      zle -N zle-keymap-select
      zle-line-init() {
        zle -K viins # initiate 'vi insert' as keymap
        echo -ne '\e[6 q'
      }
      zle -N zle-line-init
      echo -ne '\e[6 q' # Use beam shape cursor on startup

      # Yank to the system clipboard
      function vi-yank-xclip {
        zle vi-yank
        echo "$CUTBUFFER" | pbcopy -i
      }
      zle -N vi-yank-xclip
      bindkey -M vicmd 'y' vi-yank-xclip
    '';

    completionInit = ''
      # Load Git completion scripts
      zstyle ':completion:*:*:git:*' script ${config.xdg.configHome}/zsh/git-completion.bash
      fpath=(${config.xdg.configHome}/zsh $fpath)
      autoload -Uz compinit && compinit
    '';
  };

  # Git completions
  home.file = {
    "${config.xdg.configHome}/zsh/git-completion.bash".source = ./zsh/git-completion.bash;
    "${config.xdg.configHome}/zsh/git-completion.zsh".source = ./zsh/git-completion.zsh;
  };
}
