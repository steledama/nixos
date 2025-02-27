{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    autocd = true;
    dotDir = ".config/zsh";
    
    # Configura opzioni per la storia dei comandi
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      save = 10000;
      share = true;
    };
    
    # Aggiungi gli alias dalla tua configurazione attuale
    shellAliases = {
      # System aliases
      shutdown = "sudo shutdown now";
      restart = "sudo reboot";
      suspend = "sudo pm-suspend";
      sleep = "pmset sleepnow";
      c = "clear";
      e = "exit";
      
      # Git aliases
      g = "git";
      ga = "git add";
      gf = "git fetch";
      gs = "git status";
      gss = "git status -s";
      # ... altri alias da aliases.zsh
      
      # Neovim
      vi = "poetry_run_nvim";
      v = "poetry_run_nvim";
      
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
      # Import custom zsh scripts
      source ${./zsh/custom.zsh}
      
      # Funzioni da custom.zsh
      # poetry_run_nvim function
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
          commit_message="$ticket_id: ${*:2}" # take all positional parameters starting from the second one
          git commit --no-verify -m "$commit_message" && git push
        else
          git commit --no-verify -m "$commit_message"
        fi
      }
      
      # Vi mode setup
      bindkey -v
      export KEYTIMEOUT=1
      export VI_MODE_SET_CURSOR=true 

      function zle-keymap-select {
        if [[ ${KEYMAP} == vicmd ]]; then
          echo -ne '\e[2 q' # block
        else
          echo -ne '\e[6 q' # beam
        fi
      }
      zle -N zle-keymap-select
      
      zle-line-init() {
        zle -K viins
        echo -ne '\e[6 q'
      }
      zle -N zle-line-init
      echo -ne '\e[6 q'
    '';
    
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "gOG0NLlaJfotJfs+SUhGgLTNOnGLjoqnUp54V9aFJg8=";
        };
      }
    ];
  };
  
  # Copia i file di configurazione git-completion
  xdg.configFile = {
    "zsh/git-completion.bash".source = ./zsh/git-completion.bash;
    "zsh/git-completion.zsh".source = ./zsh/git-completion.zsh;
  };
  
  # Installa starship per il prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Configura starship come preferisci
      add_newline = false;
      command_timeout = 1000;
    };
  };
}