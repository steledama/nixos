# modules/home/dev-tools.nix
{
  pkgs,
  pkgs-ai,
  ...
}: {
  imports = [./pi.nix];

  # Core development tools available globally
  #
  # This is the SINGLE SOURCE OF TRUTH for:
  # - Language servers (used by Helix, Zed, and CLI)
  # - Code formatters (used by editors and CLI)
  # - AI coding agents (claude-code, codex, pi-coding-agent, from pkgs-ai for frequent updates)
  #
  # Language-specific tools (JS, Python, Rust) should be in project flakes
  #
  # Related modules:
  # - Build dependencies + Node.js: hosts/default.nix
  # - Shell utilities: modules/home/shell.nix
  # - Herdr (agent multiplexer, pkgs-ai): modules/home/herdr.nix
  # - gogcli / Google Workspace CLI (deck only): modules/home/google-workspace-cli.nix
  home.packages =
    (with pkgs; [
      # Version control
      git # Version control
      lazygit # Git TUI frontend
      gh # GitHub CLI

      # Data inspection
      sqlite # SQLite database console

      # Language runtimes (system-level only if needed by systemd services)
      (python3.withPackages (ps: with ps; [pyyaml pillow])) # Python con pyyaml per validatori skill e Pillow per immagini
      php84 # PHP runtime

      # Language Servers (LSP)
      nil # Nix LSP (fast, used by Helix and Zed)
      marksman # Markdown
      typescript-language-server # JavaScript/TypeScript
      yaml-language-server # Yaml (also used by docker-compose)
      docker-compose-language-service # Docker Compose
      dockerfile-language-server # Dockerfile
      phpactor # Php

      # Code Formatters & Linters - For auto-format in Helix/Zed and CLI
      alejandra # Nix formatter (fast, opinionated)
      prettier # JS/TS/JSON/YAML/Markdown/CSS/HTML
      eslint # JavaScript/TypeScript linter
      ruff # Python formatter and linter
      php84Packages.php-cs-fixer # PHP formatter
    ])
    # AI Coding Agents - From pkgs-ai for independent updates
    # Update with: nix flake update ai && o3/scripts/con-identita.sh home-manager switch --flake .#$USER@$(hostname)
    ++ (with pkgs-ai; [
      claude-code # Anthropic Claude Code CLI
      codex # OpenAI Codex CLI
      pi-coding-agent # Pi AI coding agent
    ]);
}
