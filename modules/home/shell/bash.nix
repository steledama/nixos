# Configure Bash
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # initialization
    initExtra = ''
      # start with neofetch info
      # neofetch
      # start with starship custom prompt
      eval "$(starship init bash)"
    '';

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
