# modules/home/claude-code.nix
# Configures Claude Code settings and status line
# - Disables auto-update (managed declaratively via Nix)
# - Disables auto-memory (project memory lives versioned in-repo, not in ~/.claude/)
# - Disables commit/PR attribution (artifacts stay model-independent)
# - Sets up custom status line showing hostname and current directory
# - Declares global user instructions (~/.claude/CLAUDE.md)
# - Pins TUI renderer (settings.json is a read-only store symlink, so
#   interactive choices can't persist and must be declared here)
{...}: {
  # Set global environment variables: disable auto-update and auto-memory.
  # auto-memory's store (~/.claude/projects/.../memory/) is machine-local and
  # unversioned; the method keeps project memory in-repo (i3/, kb/, o2/ —
  # see kb/development-environment.md, "Memoria degli agenti").
  home.sessionVariables = {
    DISABLE_AUTOUPDATER = "1";
    CLAUDE_CODE_DISABLE_AUTO_MEMORY = "1";
  };

  # Create Claude Code settings.json (in ~/.claude/ NOT ~/.config/claude/)
  home.file.".claude/settings.json" = {
    text = builtins.toJSON {
      env = {
        DISABLE_AUTOUPDATER = "1";
        CLAUDE_CODE_DISABLE_AUTO_MEMORY = "1";
      };
      # Keep the native-scrollback renderer. Do not switch this to `fullscreen`
      # as a generic terminal/Herdr workaround: the comparison reproduced on
      # 2026-08-21 with Claude Code 2.1.234 and Herdr 0.8.0 showed that the same
      # long-line fixture copied byte-complete from a plain shell and Codex,
      # while Claude's fullscreen/alternate-screen renderer dropped arbitrary
      # middle spans, merged cells and inserted large blank regions. Starting
      # Claude with CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1 made the fixture
      # complete again. The default renderer still copies its own two-column
      # gutter and hard line breaks at the TUI width; those are known upstream
      # Claude Code formatting defects, but they are non-destructive. Therefore
      # evidence points to Claude fullscreen's interaction with the terminal
      # grid, not to foot, Herdr's ordinary selection or the Wayland clipboard.
      tui = "default";
      # No Co-Authored-By trailer nor PR attribution, in any repo (custodian's
      # decision, 2026-10-05). The method's goal wants artifacts independent of
      # the model that wrote them, and the canonical /commit skill forbids the
      # trailer; a rule in a skill is not enough, because the harness itself
      # appends it (danea-auto: 23 commits since 2026-09-25 despite its fork).
      # `attribution` is the key read by Claude Code 2.1.x; the older
      # `includeCoAuthoredBy` is deprecated, so it is deliberately not set.
      # Object form, not `false`: older versions reject the boolean.
      attribution = {
        commit = "";
        pr = "";
      };
      statusLine = {
        type = "command";
        command = "~/.claude/statusline-command.sh";
      };
    };
  };

  # Global user instructions, valid in every repo on every host that imports
  # this module. Personal preferences only: project rules stay in each
  # repository's CLAUDE.md.
  home.file.".claude/CLAUDE.md".text = ''
    # Preferenze personali

    - In italiano dai sempre del tu all'utente, mai del lei: il registro
      formale mette una distanza che l'utente non vuole.
    - Quando scrivi o aggiorni una memoria in `~/.claude/projects/*/memory/`,
      mostra subito all'utente il contenuto della memoria appena scritta,
      titolo e corpo, in forma leggibile. Non serve mostrarle all'avvio di
      ogni sessione.
  '';

  # Create status line script (minimal: hostname + directory)
  home.file.".claude/statusline-command.sh" = {
    text = ''
      #!/usr/bin/env bash
      # Read directory from stdin (JSON) or use PWD
      if read -t 0.1 input 2>/dev/null; then
          cwd=$(echo "$input" | jq -r '.workspace.current_dir' 2>/dev/null)
          [[ -z "$cwd" || "$cwd" == "null" ]] && cwd="$PWD"
      else
          cwd="$PWD"
      fi
      # Replace $HOME with ~
      cwd="''${cwd/#$HOME/~}"
      # Output: hostname directory
      printf "%s %s" "$(hostname -s)" "$cwd"
    '';
    executable = true;
  };
}
