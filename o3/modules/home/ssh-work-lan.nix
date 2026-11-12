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
    # PC Danea, Windows: sshd con shell cmd, utente danea, solo per leggere il
    # checkout di danea-auto da deck (method, 2026-11-12).
    danea2 = {
      HostName = identity.work.lan.devices.danea2;
      User = "danea";
      IdentityFile = "~/.ssh/id_ed25519";
    };
  };
}
