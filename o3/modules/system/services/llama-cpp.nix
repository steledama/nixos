# modules/system/services/llama-cpp.nix
# Declarative llama.cpp server with on-demand chat and OCR models.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.llamaCppServer;

  qwenChat = pkgs.fetchurl {
    name = "Qwen3.8-27B-UD-IQ3_XXS.gguf";
    url = "https://huggingface.co/unsloth/Qwen3.8-27B-GGUF/resolve/4ca720788d1e01f1bff70c033e0d0028fd02e502/Qwen3.8-27B-UD-IQ3_XXS.gguf?download=true";
    hash = "sha256-wLfDA4aB7S4wQEVsHdRfmFi2wikL7RcscDiKlIdPPu4=";
  };

  # MiniCPM-OCR 1.0: main Q8, F16 4x projector and matching DSpark head.
  miniOcr = pkgs.fetchurl {
    name = "MiniCPM-OCR-1_0-Q8_0.gguf";
    url = "https://huggingface.co/openbmb/MiniCPM-OCR-1.0-gguf/resolve/0133ad8db635210441a55dcf421e25bfb9915142/MiniCPM-OCR-1_0-Q8_0.gguf?download=true";
    hash = "sha256-eRSGpHa9rLSKyz8xqjoY27W+h+cjpAdLzROjfWHIUuI=";
  };

  miniOcrMmproj = pkgs.fetchurl {
    name = "mmproj-model-f16-4x.gguf";
    url = "https://huggingface.co/openbmb/MiniCPM-OCR-1.0-gguf/resolve/0133ad8db635210441a55dcf421e25bfb9915142/mmproj-model-f16-4x.gguf?download=true";
    hash = "sha256-zu2CJhs7E4DDFl+LN8EBF6UAk74TYsv+62kvoDZERoI=";
  };

  miniOcrDraft = pkgs.fetchurl {
    name = "dspark-MiniCPM-OCR-1_0-Q8_0.gguf";
    url = "https://huggingface.co/openbmb/MiniCPM-OCR-1.0-DSpark-gguf/resolve/cab493a5a26516a1c4c6e07c73b4470ff854a898/dspark-MiniCPM-OCR-1_0-Q8_0.gguf?download=true";
    hash = "sha256-/Y9ku2LPWlxrTAmZv6WPZEU2kMn3XxEkq2E9+0SoIto=";
  };

  modelsPreset = pkgs.writeText "llama-cpp-models.ini" ''
    version = 1

    [*]
    n-gpu-layers = all
    parallel = 1
    load-on-startup = false

    [qwen3.8-27b-iq3_xxs]
    model = ${qwenChat}
    ctx-size = ${toString cfg.chatContextSize}
    cache-type-k = q4_0
    cache-type-v = q4_0

    [minicpm-ocr]
    model = ${miniOcr}
    mmproj = ${miniOcrMmproj}
    model-draft = ${miniOcrDraft}
    spec-type = draft-dspark
    spec-draft-n-max = 15
    gpu-layers-draft = all
    flash-attn = on
    jinja = true
    reasoning = off
    ctx-size = ${toString cfg.ocrContextSize}
  '';
in {
  options.services.llamaCppServer = {
    enable = lib.mkEnableOption "llama.cpp multi-model server";

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Start the server at boot. When false the unit stays installed but is
        started by hand (systemctl start llama-cpp), and a switch leaves it
        as it is.
      '';
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address on which the llama.cpp server listens.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
      description = "Port used by the llama.cpp server.";
    };

    chatContextSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 32768;
      description = "Context size for the Qwen chat model.";
    };

    ocrContextSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 8192;
      description = "Context size for the MiniCPM-OCR model.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.llama-cpp = {
      enable = true;
      package = pkgs.llama-cpp;
      openFirewall = false;
      settings = {
        inherit (cfg) host port;
        cors-origins = "localhost";
        models-preset = modelsPreset;
        models-max = 1;
        models-autoload = true;
      };
    };

    systemd.services.llama-cpp.wantedBy = lib.mkIf (!cfg.autoStart) (lib.mkForce []);
  };
}
