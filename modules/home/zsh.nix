# nixos/modules/home/zsh.nix

{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    # Configurazione minimalista per la history
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreAllDups = true;
      share = true;
    };

    # Aliases
    shellAliases = {
      # navigation
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

    # Configurazione del sistema di completamento
    completionInit = ''
      # Inizializzazione del sistema di completamento
      autoload -Uz compinit && compinit

      # Opzioni di completamento utili
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' verbose true
      zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'

      # Binding del tab per il completamento
      bindkey '^I' complete-word
      bindkey '^[[Z' reverse-menu-complete
    '';

    # Init base config
    initExtra = ''
      # Starship integration
      eval "$(starship init zsh)"

      # Zoxide integration - zsh specific
      eval "$(zoxide init zsh)"

      # direnv integration - zsh specific
      eval "$(direnv hook zsh)"

      # Tmux auto-start
      if [[ -z "$TMUX" && "$TERM" != "screen"* ]]; then
        tmux attach || tmux new
      fi

      # FZF base setup
      if [ -f "$HOME/.fzf.zsh" ]; then 
        source "$HOME/.fzf.zsh"
      fi
    '';
  };

  # Aggiungi i completamenti extra per Zsh
  home.packages = with pkgs; [
    zsh-completions
  ];
}
