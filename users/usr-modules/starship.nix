# starship module
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$shlvl$time$username$hostname$nix_shell$git_branch$git_commit$git_state$git_status$directory$jobs$cmd_duration$character";

      shlvl = {
        disabled = false;
        symbol = "⚡";
        style = "bright-red bold";
      };

      time = {
        disabled = false;
        format = "[$time]($style) ";
        time_format = "%d/%m %R";
        style = "bright-white";
      };

      username = {
        style_user = "bright-white bold";
        style_root = "bright-red bold";
      };

      git_branch = {
        symbol = "⎇ ";
        style = "bright-purple";
        format = "on [$symbol$branch]($style) ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "bright-purple";
        conflicted = "≠";
        ahead = "↑";
        behind = "↓";
        diverged = "⇕";
        up_to_date = "✓";
        untracked = "?";
        stashed = "$";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "×";
      };

      character = {
        success_symbol = "[❯](bright-green)";
        error_symbol = "[❯](bright-red)";
      };
    };
  };
}
