# nixos/modules/home/dev-tools.nix
{pkgs, ...}: {
  # Development-specific packages that should be user-specific rather than system-wide
  home.packages = with pkgs; [
    # Development tools
    git # Version control
    lazygit # Git TUI frontend
    gh # GitHub CLI
    gcc # C compiler
    direnv # Shell extension that manages your environment
    openssl # Cryptographic library that implements the SSL and TLS protocols
    claude-code # Agentic coding tool
    gemini-cli # AI agent into your terminal

    # Language runtimes
    nodejs # Event-driven I/O framework for the V8 JavaScript engine
    rustup # Rust toolchain installer (includes cargo)
    python3 # High-level dynamically-typed programming language

    # Language servers
    nil # Nix
    nixd # Nix
    lua-language-server # Lua
    typescript-language-server # Js
    pyright # python

    # Formatters
    prettierd # JavaScript
    stylua # Lua
    alejandra # Nix
    black # Python
    isort # Python

    # Linters
    eslint # JavaScript
    lua54Packages.luacheck # Lua
    nixpkgs-fmt # Nix (alternativa ad alejandra)
    pylint # Python
  ];
}
