# modules/system/shell.nix
{pkgs, ...}: {
  # Enable fish shell (but NOT as default login shell)
  # Fish is not POSIX compliant and causes issues as login shell, particularly via SSH
  # See: https://wiki.nixos.org/wiki/Fish
  programs.fish.enable = true;

  # Use bash as default login shell (POSIX compliant, stable for SSH/system)
  # Bash will automatically launch fish for interactive sessions
  users.defaultUserShell = pkgs.bash;

  # Configure bash to automatically launch fish for interactive shells
  # This gives users fish for day-to-day work while keeping bash for login/system tasks
  programs.bash = {
    interactiveShellInit = ''
      # Auto-launch fish for interactive shells (but not for scripts or non-interactive sessions)
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        # PATH-aware: preferisce la fish del profilo home-manager (pin nixpkgs
        # principale, ~/.nix-profile precede il sistema nel PATH); fallback
        # alla fish di sistema per utenti senza profilo home (root incluso).
        FISH_BIN=$(type -P fish) || FISH_BIN=${pkgs.fish}/bin/fish
        exec "$FISH_BIN" $LOGIN_OPTION
      fi
    '';
  };
}
