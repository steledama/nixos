# starship module
{
  programs.starship.enable = true;
  programs.starship.settings = {
    add_newline = false;
    format = "$shlvl$time$username$hostname$nix_shell$git_branch$git_commit$git_state$git_status$directory$jobs$cmd_duration$character";
    shlvl = {
      disabled = false;
      symbol = "ﰬ";
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
  };
}
