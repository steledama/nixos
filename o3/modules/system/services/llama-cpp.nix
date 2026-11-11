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

  glmOcr = pkgs.fetchurl {
    name = "GLM-OCR-Q8_0.gguf";
    url = "https://huggingface.co/ggml-org/GLM-OCR-GGUF/resolve/306e9d8bfd97fb453adad15d2f2220d0a2ce2133/GLM-OCR-Q8_0.gguf?download=true";
    hash = "sha256-RbwkSmRGr/hQUh3EHxi8jXEFrV8MLIworwTnzE9NULE=";
  };

  glmOcrMmproj = pkgs.fetchurl {
    name = "mmproj-GLM-OCR-Q8_0.gguf";
    url = "https://huggingface.co/ggml-org/GLM-OCR-GGUF/resolve/964d28c9e3c3330b0f322235abefdcdd29116eb7/mmproj-GLM-OCR-Q8_0.gguf?download=true";
    hash = "sha256-nEtY4z4xbtFC613LQavsOETT5uXcNh/7eCw/qdF1FB8=";
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

    [glm-ocr-q8_0]
    model = ${glmOcr}
    mmproj = ${glmOcrMmproj}
    ctx-size = ${toString cfg.ocrContextSize}
    cache-type-k = q8_0
    cache-type-v = q8_0
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
      description = "Context size for the GLM-OCR model.";
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
