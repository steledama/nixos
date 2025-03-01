# modules/system/shell.nix
{ config, lib, pkgs, ... }:

{
  # Enable bash at system level
  programs.bash = {
    enable = true;
    # Completion handled at user level
  };

  # Enable zsh at system level
  programs.zsh = {
    enable = true;
    # Completion handled at user level
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Set zsh as default shell for new users
  users.defaultUserShell = pkgs.zsh;

  # Shell-related packages at system level
  environment.systemPackages = with pkgs; [
    starship    # Customizable prompt
    zoxide      # Smarter cd command
    direnv      # Environment manager
    tmux        # Terminal multiplexer
    fzf         # Fuzzy finder
    bat         # Better cat
    eza         # Better ls
    fd          # Better find
    ripgrep     # Better grep
    zsh-completions
  ];
  
  # Configure keyd for CapsLock to Ctrl+b (for tmux)
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            capslock = "C-b";
          };
        };
      };
    };
  };
}