{
  config,
  lib,
  ...
}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      ServerAliveInterval = 60;
      ServerAliveCountMax = 3;
    };
  };

  home.file.".ssh/config".force = true;

  # OpenSSH 10 rejects Home Manager's store symlink for ~/.ssh/config.
  home.activation.materializeSshConfig = lib.hm.dag.entryAfter ["linkGeneration"] ''
    config_file="${config.home.homeDirectory}/.ssh/config"
    if [ -L "$config_file" ]; then
      config_target="$(readlink -f "$config_file")"
      rm "$config_file"
      install -m 600 "$config_target" "$config_file"
    elif [ -f "$config_file" ]; then
      chmod 600 "$config_file"
    fi
  '';
}
