# secrets.nix
# Elenco delle chiavi pubbliche che possono decriptare i segreti.
[
  # host pc-sviluppo (cat ~/.ssh/id_ed25519_lavoro.pub)
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKC7Z3/Wyne1vVN86hRloOOQeIsc+QrR1Udu1a88QsYt sviluppo@toscanatradingsrl.com"
  # utente sviluppo (cat /etc/ssh/ssh_host_ed25519_key.pub)
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOELuR4zIQaRDfTjEwRc2xVv7XxP7Kr26+hz6FUN01S2 root@pc-sviluppo"

  # srv-norvegia (cat ~/.ssh/id_ed25519_tt.pub)
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeyGIAqC2i8jjUQQ2rPhnleRCgb4VMu3Va5hIuxQvR9 acquisti@toscanatradingsrl.com"
  # utente acquisti (cat /etc/ssh/ssh_host_ed25519_key.pub)
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTjpaHedOlukCCN1px54Hzhm2D1h5rf3kj0DKPFCc89 root@acquisti-laptop"
]
