# Configure system shells
{
  # Bash configuration at system level
  programs.bash = {
    completion.enable = true;
  };

  # Zsh configuration at system level
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };
}
