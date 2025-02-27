# nixos/modules/home/bash.nix

{
  programs.bash = {
    enable = true;
    enableCompletion = true;

    # initialization
    initExtra = ''
      # start with neofetch info
      # neofetch
      # add direnv hook
      eval "$(direnv hook bash)"
    '';
    # aliases
    shellAliases = {
      gcCleanup = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot && sudo nvim /boot/loader/loader.conf";
      v = "nvim";
      sv = "sudo nvim";
      ll = "ls -l";
      la = "ls -a";
      lal = "ls -al";
      ".." = "cd ..";
    };
  };
}
