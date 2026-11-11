# modules/home/git.nix
# Git configuration with user-specific settings
{...}: {
  programs.git = {
    enable = true;
    signing.format = null; # Nuovo default 25.05: nessuna firma GPG
    settings = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };
}
