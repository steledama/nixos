# modules/home/google-workspace-cli.nix
{pkgs, ...}: {
  # gogcli: CLI Google Workspace (Gmail, Calendar, Drive) — sostituisce i
  # server MCP Gmail/Calendar (kb/google-workspace-cli.md).
  home.packages = with pkgs; [
    gogcli # Google APIs CLI (Gmail, Calendar, Drive) — binario `gog`, Go, in uso operativo
  ];
}
