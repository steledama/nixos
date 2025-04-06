{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.extraServices.ollama;
in {
  options.extraServices.ollama.enable = mkEnableOption "enable ollama";

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama;
      acceleration =
        if config.services.xserver.videoDrivers == ["amdgpu"]
        then "rocm"
        else if config.services.xserver.videoDrivers == ["nvidia"]
        then "cuda"
        else null;
      host = "[::]";
      # port = 11434; # default is 11434
      openFirewall = true;
    };
    nixpkgs.config = {
      rocmSupport = config.services.xserver.videoDrivers == ["amdgpu"];
      cudaSupport = config.services.xserver.videoDrivers == ["nvidia"];
    };
  };
}
