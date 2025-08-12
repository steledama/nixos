# secrets.nix
# Definizione dei segreti e delle chiavi pubbliche autorizzate
let
  # Chiavi pubbliche degli host
  pc-sviluppo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOELuR4zIQaRDfTjEwRc2xVv7XxP7Kr26+hz6FUN01S2 root@pc-sviluppo";
  pc-game = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINWibWqi41TnSUhl4Insc7vHXfnRFng2znNZ/ofKVX2X root@pcgame";
  srv-norvegia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTjpaHedOlukCCN1px54Hzhm2D1h5rf3kj0DKPFCc89 root@acquisti-laptop";
  
  # Chiavi pubbliche degli utenti (se necessarie)
  stefano = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKC7Z3/Wyne1vVN86hRloOOQeIsc+QrR1Udu1a88QsYt sviluppo@toscanatradingsrl.com";
  acquisti = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeyGIAqC2i8jjUQQ2rPhnleRCgb4VMu3Va5hIuxQvR9 acquisti@toscanatradingsrl.com";
in
{
  # Segreto SMB esistente
  "smb-secrets.age".publicKeys = [ pc-sviluppo srv-norvegia ];
  
  # Nuovi segreti SSH per stefano
  "secrets/ssh-stefano-norvegia.age".publicKeys = [ pc-game ];
  "secrets/ssh-stefano-github.age".publicKeys = [ pc-game ];
}
