# Configure system shells
{
  # Bash configuration
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # Other global configs
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    # Other global configs
  };

  # Other shells
}
