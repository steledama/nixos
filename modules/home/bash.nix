# nixos/modules/home/bash.nix

{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;

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

    # Init base config
    initExtra = ''
      # Starship integration
      eval "$(starship init bash)"

      # Zoxide integration - bash specific
      eval "$(zoxide init bash)"

      # direnv integration - bash specific
      eval "$(direnv hook bash)"

      # Tmux auto-start
      if [ -z "$TMUX" ] && [ "$TERM" != "screen" ]; then
        tmux attach || tmux new
      fi

      # FZF base setup
      if [ -f "$HOME/.fzf.bash" ]; then 
        source "$HOME/.fzf.bash"
      fi
    '';
  };
}
