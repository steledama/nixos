# modules/home/codex.nix
# Codex CLI: turns local memories off, like claude-code.nix does for Claude
# Code's auto-memory. The store ($CODEX_HOME/memories/, memories_*.sqlite) is
# machine-local and unversioned; project memory lives in-repo (kb/, i3/, o2/ —
# see kb/development-environment.md, "Memoria degli agenti").
#
# Codex documents no environment variable for this, only config.toml keys
# (learn.chatgpt.com/docs/customization/memories and
# learn.chatgpt.com/docs/config-file/config-reference):
# - features.memories: the feature itself, off by default; pinned to false so
#   a changed default or a UI toggle cannot turn it back on silently;
# - memories.generate_memories / memories.use_memories: no new chats become
#   memory inputs, no existing memory is injected, should the feature return.
{
  config,
  lib,
  pkgs,
  ...
}: let
  python = pkgs.python3.withPackages (ps: [ps.tomlkit]);
  # `codex features disable memories` is not enough: with the feature already
  # off by default it leaves config.toml untouched, so nothing is pinned.
  mergeConfig = pkgs.writeText "codex-merge-config.py" ''
    import os, sys, tomlkit

    path = sys.argv[1]
    try:
        with open(path) as f:
            doc = tomlkit.parse(f.read())
    except FileNotFoundError:
        doc = tomlkit.document()

    managed = {
        "features": {"memories": False},
        "memories": {"generate_memories": False, "use_memories": False},
    }
    for table, keys in managed.items():
        if table not in doc:
            doc[table] = tomlkit.table()
        for key, value in keys.items():
            doc[table][key] = value

    tmp = path + ".tmp"
    fd = os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w") as f:
        f.write(tomlkit.dumps(doc))
    os.replace(tmp, path)
  '';
in {
  # Codex rewrites config.toml itself (projects' trust_level, TUI notices), so
  # it cannot be a store symlink: merge the managed keys into it on every
  # activation and leave the rest to Codex.
  home.activation.mergeCodexConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "${config.home.homeDirectory}/.codex"
    run ${python}/bin/python3 ${mergeConfig} "${config.home.homeDirectory}/.codex/config.toml"
  '';
}
