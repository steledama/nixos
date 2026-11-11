# Servizio di deck: riceve le misure fuori dal checkout, senza modificarlo.
{pkgs, ...}: let
  registry = import ../../pressione.nix;
in {
  systemd.user.services.pressione-salute = {
    Unit = {
      Description = "Inserimento delle misure pressorie sulle reti private";
      ConditionPathExists = "%h/salute/o3/pressione/serve.py";
      StartLimitIntervalSec = 300;
      StartLimitBurst = 5;
    };
    Service = {
      WorkingDirectory = "%h/salute";
      ExecStartPre = "${pkgs.coreutils}/bin/touch %S/${registry.stateDirectory}/inserite.jsonl";
      ExecStart = "${pkgs.python3}/bin/python3 o3/pressione/serve.py --port ${toString registry.port} --inbox %S/${registry.stateDirectory}/inserite.jsonl";
      Environment = "PYTHONDONTWRITEBYTECODE=1";
      StateDirectory = registry.stateDirectory;
      StateDirectoryMode = "0700";
      UMask = "0077";
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      PrivateTmp = true;
      NoNewPrivileges = true;
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = ["default.target"];
  };
}
