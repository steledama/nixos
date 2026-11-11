# Additional SSH identities are local data; host and key names stay unchanged.
{identity, ...}: {
  programs.ssh.settings = identity.home.extraSsh;
}
