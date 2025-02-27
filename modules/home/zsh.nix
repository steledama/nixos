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

    # Alias essenziali
    shellAliases = {
      # Navigazione
      ".." = "cd ..";
      "..." = "cd ../..";

      # Utility di sistema
      ll = "ls -l";
      la = "ls -a";
      lal = "ls -al";
      c = "clear";
      e = "exit";

      # Comandi NixOS
      nrb = "sudo nixos-rebuild switch --flake .";
      nup = "nix flake update";
      ngc = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d";

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

      # Utilizzo di strumenti moderni
      ls = "eza --icons=always";
      cat = "bat";
      find = "fd";
      grep = "rg";
    };

    # Configurazione base
    initExtra = ''
      # Integrazione Starship
      eval "$(starship init zsh)"

      # Integrazione direnv
      eval "$(direnv hook zsh)"

      # Tmux auto-start (versione minimalista)
      if [[ -z "$TMUX" && "$TERM" != "screen"* ]]; then
        tmux attach || tmux new
      fi

      # FZF base setup se installato
      if [ -f "$HOME/.fzf.zsh" ]; then 
        source "$HOME/.fzf.zsh"
      fi
    '';
  };

  # Starship viene gestito dal modulo dedicato
}
