# nixos/modules/home/starship.nix

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Installazione del pacchetto Starship
  home.packages = with pkgs; [
    starship
  ];

  # Configurazione esplicita per Starship
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = {
      # Configurazione minimalista
      add_newline = false;
      command_timeout = 1000;

      # Carattere del prompt
      character = {
        success_symbol = "[➜](green)";
        error_symbol = "[✗](red)";
        vicmd_symbol = "[V](green)";
      };

      # Moduli visibili
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };

      # Personalizzazioni dei moduli
      cmd_duration = {
        min_time = 500;
        format = "[$duration]($style) ";
      };

      # Disabilita moduli non essenziali
      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = true;
      package.disabled = true;
      ruby.disabled = true;
      docker_context.disabled = true;
      buf.disabled = true;

      # Nix shell
      nix_shell = {
        disabled = false;
        format = "[❄️ $name]($style) ";
      };

      # Git conciso
      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = "🌿 ";
      };

      git_status = {
        format = "([●](red)[$all_status$ahead_behind]($style))";
        conflicted = "≠";
        ahead = "⇡${count}";
        behind = "⇣${count}";
        diverged = "⇕⇡${ahead_count}⇣${behind_count}";
        untracked = "?${count}";
        stashed = "\\$${count}";
        modified = "!${count}";
        staged = "+${count}";
        renamed = "»${count}";
        deleted = "✘${count}";
      };
    };
  };
}
