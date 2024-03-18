{ pkgs, config, lib, ... }:

{
  # Configure Bash
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # neofetch and starship initialization
    initExtra = ''
      neofetch
      eval "$(starship init bash)"
    '';

    shellAliases = {
      gcCleanup = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d";
      v = "nvim";
      sv = "sudo nvim";
      ll = "ls -l";
      la = "ls -a";
      lal = "ls -al";
      ".." = "cd ..";
    };
  };
}
