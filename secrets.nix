# secrets.nix
# Definizione dei segreti e delle chiavi pubbliche autorizzate
let
  # Chiavi pubbliche degli host
  pc-sviluppo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOELuR4zIQaRDfTjEwRc2xVv7XxP7Kr26+hz6FUN01S2 root@pc-sviluppo";
  srv-norvegia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTjpaHedOlukCCN1px54Hzhm2D1h5rf3kj0DKPFCc89 root@srv-norvegia";
  
  # Chiavi pubbliche degli utenti (se necessarie)
  norvegia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeyGIAqC2i8jjUQQ2rPhnleRCgb4VMu3Va5hIuxQvR9 norvegia@toscanatradingsrl.com";
in
{
  # Segreto SMB esistente
  "smb-secrets.age".publicKeys = [ pc-sviluppo srv-norvegia ];
}
