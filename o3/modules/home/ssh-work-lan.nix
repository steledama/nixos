{identity, ...}: let
  mkHost = {
    hostname,
    port ? 22,
  }: {
    HostName = hostname;
    Port = port;
    User = "sviluppo";
    IdentityFile = "~/.ssh/id_ed25519";
    SetEnv = {
      TERM = "xterm-256color";
      COLORTERM = "truecolor";
    };
  };
in {
  programs.ssh.settings = {
    norvegia = mkHost {hostname = identity.work.lan.hosts.norvegia;};
    svezia = mkHost {hostname = identity.work.lan.hosts.svezia;};
  };
}
