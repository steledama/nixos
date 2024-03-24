{ pkgs, config, lib, ... }:
{
  # Configure wezterm
  programs.wezterm = {
    enable = true;
    package = pkgs.wezterm;
    enableBashIntegration = true;
    # extraConfig = '''';
  };
}


