{identity, ...}: let
  mkHost = {
    hostname,
    user,
    port ? 22,
  }: {
    HostName = hostname;
    User = user;
    Port = port;
    IdentityFile = "~/.ssh/id_ed25519";
    SetEnv = {
      TERM = "xterm-256color";
      COLORTERM = "truecolor";
    };
  };
in {
  programs.ssh.settings = {
    deck = mkHost {
      hostname = identity.home.lan.hosts.deck;
      user = "stele";
    };
    neve = mkHost {
      hostname = identity.home.lan.hosts.neve;
      user = "stele";
    };
    game = mkHost {
      hostname = identity.home.lan.hosts.game;
      user = "stele";
    };
  };
}
