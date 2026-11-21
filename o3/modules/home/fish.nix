# modules/home/fish.nix
# Fish shell configuration with builtin prompt
# For prompt customization, run: fish_config
# Shell-agnostic utilities (fzf, direnv, zoxide) are in modules/home/shell.nix
{pkgs, ...}: {
  programs.fish = {
    enable = true;

    # Required for NixOS environment integration
    plugins = [
      {
        name = "foreign-env";
        src = pkgs.fishPlugins.foreign-env.src;
      }
    ];

    # Generate completions from man pages automatically.
    # Disabilitato: fish 4.8.0 ha rimosso share/fish/tools/create_manpage_completions.py,
    # che home-manager invoca per questa feature → il build delle completions fallisce.
    # Fish 4.x porta comunque molte completions di suo. Riabilitare quando nixpkgs/home-manager
    # tornano allineati.
    generateCompletions = false;

    # Shell initialization (non-interactive)
    shellInit = ''
      set -gx EDITOR hx
      set -gx VISUAL hx
      # Enable true color support for terminal applications
      set -gx COLORTERM truecolor
    '';

    # Fish abbreviations (expand on typing, more efficient than aliases)
    shellAbbrs = {
      # Common shortcuts
      ll = "ls -lah";
      ".." = "cd ..";
      "..." = "cd ../..";
      # Git abbreviations
      gs = "git status";
      gp = "git push";
      gl = "git pull";

      # NixOS abbreviations
      # Sempre col wrapper: il flake nudo costruisce i template pubblici.
      nrs = "./o3/scripts/con-identita.sh sudo nixos-rebuild switch --flake .";
      hms = "./o3/scripts/con-identita.sh home-manager switch --flake .#$USER@(hostname)";
      ngc = "nix-collect-garbage -d && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
    };

    # Interactive shell initialization
    interactiveShellInit = ''
      # Disabilita messaggio di benvenuto
      set -g fish_greeting

      # Configurazione git prompt per mostrare status completo
      set -g __fish_git_prompt_showdirtystate 1
      set -g __fish_git_prompt_showstashstate 1
      set -g __fish_git_prompt_showuntrackedfiles 1
      set -g __fish_git_prompt_showupstream auto
      set -g __fish_git_prompt_show_informative_status 1

      # Simboli git status
      set -g __fish_git_prompt_char_dirtystate '✗'
      set -g __fish_git_prompt_char_stagedstate '✓'
      set -g __fish_git_prompt_char_untrackedfiles '?'
      set -g __fish_git_prompt_char_stashstate '⚑'
      set -g __fish_git_prompt_char_upstream_ahead '↑'
      set -g __fish_git_prompt_char_upstream_behind '↓'

      # Colori git prompt - Catppuccin Mocha palette
      set -g __fish_git_prompt_color_branch a6e3a1 --bold      # Branch pulito: green
      set -g __fish_git_prompt_color_branch_dirty f9e2af       # Branch con modifiche: yellow
      set -g __fish_git_prompt_color_branch_staged 94e2d5      # Branch con staged: teal

      # Colori per stati specifici
      set -g __fish_git_prompt_color_dirtystate f9e2af         # Modifiche non staged: yellow
      set -g __fish_git_prompt_color_stagedstate 94e2d5        # Modifiche staged: teal
      set -g __fish_git_prompt_color_untrackedfiles f38ba8     # File non tracciati: red
      set -g __fish_git_prompt_color_stashstate cba6f7         # Stash presente: mauve
      set -g __fish_git_prompt_color_upstream_ahead a6e3a1     # Ahead di origin: green
      set -g __fish_git_prompt_color_upstream_behind f38ba8    # Behind di origin: red

      # Colori per stati puliti/non puliti
      set -g __fish_git_prompt_color_cleanstate a6e3a1 --bold  # Repository pulito: green
    '';

    # Prompt personalizzato con git status
    # Colori: Catppuccin Mocha palette
    functions = {
      fish_prompt = ''
        # Indicatore ambiente nix (se dentro nix develop)
        if set -q IN_NIX_SHELL
          set_color f9e2af  # Catppuccin yellow
          echo -n "[$IN_NIX_SHELL] "
          set_color normal
        end

        # User@hostname
        set_color 89dceb  # Catppuccin sky
        echo -n "$USER"
        set_color normal
        echo -n "@"
        set_color a6e3a1  # Catppuccin green
        echo -n (prompt_hostname)
        set_color normal
        echo -n " "

        # Current directory
        set_color 89b4fa  # Catppuccin blue
        echo -n (prompt_pwd)
        set_color normal

        # Git status
        set -l git_prompt (fish_git_prompt)
        if test -n "$git_prompt"
          echo -n " $git_prompt"
        end

        # Prompt symbol
        echo -n "> "
      '';
    };
  };

  # Note: Fish has builtin features that replace ZSH plugins:
  # - Autosuggestions (builtin, no plugin needed)
  # - Syntax highlighting (builtin, no plugin needed)
  # - Smart completions based on man pages (builtin)
  # - Web-based configuration interface (fish_config)
}
