# modules/system/shell.nix
{ pkgs
, ...
}: {
  # Enable zsh at system level (bash is enabled by default)
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Set zsh as default shell and editor for new users
  users.defaultUserShell = pkgs.zsh;

  # Shell-related packages at system level
  environment.systemPackages = with pkgs; [
    zsh-completions
  ];

}

