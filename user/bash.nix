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
      gcCleanup="nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      v="nvim";
      sv="sudo nvim";
      ls="lsd";
      ll="lsd -l";
      la="lsd -a";
      lal="lsd -al";
      ".."="cd ..";
    };
  };
}
