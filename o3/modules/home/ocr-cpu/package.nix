# CPU-only OCR with immutable models; no model registry is used at runtime.
{
  lib,
  python312,
  fetchurl,
  linkFarm,
  writeShellApplication,
  autoPatchelfHook,
  libglvnd,
  glib,
  stdenv,
  libsm,
  libice,
  runCommand,
  dejavu_fonts,
}: let
  python = python312.override {
    packageOverrides = final: prev: {
      # Same prebuilt Rust extensions as the pilot; their upstream test suites
      # otherwise pull in Torch/Triton, unrelated to CPU OCR inference.
      safetensors = final.buildPythonPackage {
        pname = "safetensors";
        version = "0.8.0";
        format = "wheel";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/28/50/f203ff3a3ddfe19308efc83c5a3a29ed02bf786732ec35e68bf9162f3365/safetensors-0.8.0-cp310-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
          hash = "sha256:fd6f3f93c9a0a7cc2788ee63fb763353d4bd2e89b0751bc78fcf7dda00bea774";
        };
        nativeBuildInputs = [autoPatchelfHook];
        buildInputs = [stdenv.cc.cc.lib];
        pythonImportsCheck = ["safetensors"];
        meta.license = lib.licenses.asl20;
      };
      hf-xet = final.buildPythonPackage {
        pname = "hf-xet";
        version = "1.8.0";
        format = "wheel";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/f8/1e/1e8ecc05ef034e9a95c18ed32d2ec07905a7cd2ca611a9d88e25ee1f4850/hf_xet-1.8.0-cp38-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.whl";
          hash = "sha256:29dab7c904cd1914a0439c6e1306c12c7497c8bd32290fbe563ebf51ca4b6d6d";
        };
        nativeBuildInputs = [autoPatchelfHook];
        buildInputs = [stdenv.cc.cc.lib];
        pythonImportsCheck = ["hf_xet"];
        meta.license = lib.licenses.asl20;
      };
      # Official CPU wheels: same versions validated in the pilot, no C++ build.
      paddlepaddle = prev.paddlepaddle.overridePythonAttrs (_: {
        version = "3.3.1";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/a0/03/f59f706902aad55a1f216c98fc55187945d6ccda6fdeccd226928bcc06c6/paddlepaddle-3.3.1-cp312-cp312-manylinux1_x86_64.whl";
          hash = "sha256:9016fc497213e1101261684321fbb31ef5960019ef39cb07ded27bc70e2a9858";
        };
      });
      opencv-contrib-python = final.buildPythonPackage {
        pname = "opencv-contrib-python";
        version = "4.10.0.84";
        format = "wheel";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/b0/e0/8f5d065ebb2e5941d289c5f653f944318f9e418bc5167bc6a346ab5e0f6a/opencv_contrib_python-4.10.0.84-cp37-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
          hash = "sha256:a261223db41f6e512d76deaf21c8fcfb4fbbcbc2de62ca7f74a05f2c9ee489ef";
        };
        nativeBuildInputs = [autoPatchelfHook];
        buildInputs = [libglvnd glib stdenv.cc.cc.lib libsm libice];
        dependencies = [final.numpy];
        pythonImportsCheck = ["cv2"];
        meta.license = lib.licenses.asl20;
      };
      # The upstream OCR package only needs the inference core. The nixpkgs
      # recipe still lists training/PDF extras, including Torch and MuPDF.
      paddleocr = prev.paddleocr.overridePythonAttrs (_: {
        dependencies = with final; [
          paddlex
          pyyaml
          requests
          aiohttp
          typing-extensions
          paddlepaddle
          opencv-contrib-python
          imagesize
          pyclipper
          pypdfium2
          python-bidi
          shapely
        ];
      });
      # Registry downloaders are unused with fixed local weights. Exclude the
      # insecure ModelScope and unfree AIStudio optional clients.
      paddlex = prev.paddlex.overridePythonAttrs (old: {
        dependencies = builtins.filter (p: !(builtins.elem (p.pname or "") ["modelscope" "aistudio-sdk"])) old.dependencies;
        pythonRemoveDeps = (old.pythonRemoveDeps or []) ++ ["modelscope" "aistudio-sdk"];
        patches = (old.patches or []) ++ [./paddlex-optional-downloaders.patch];
      });
    };
  };
  runtime = python.withPackages (ps: [ps.paddleocr]);
  model = name: rev: hashes:
    linkFarm name (lib.mapAttrsToList (file: hash: {
        name = file;
        path = fetchurl {
          url = "https://huggingface.co/PaddlePaddle/${name}/resolve/${rev}/${file}";
          inherit hash;
        };
      })
      hashes);
  detection = model "PP-OCRv6_small_det" "106c97591b235f607453300d9fc8c1cad1b25488" {
    "inference.json" = "sha256:89240f689a4a77aad75ef55a8df0a15c8e1d4980a327d17e58f24bbadde5aeab";
    "inference.pdiparams" = "sha256:5043d4ccc8d63402ccea8feefcee4db57077431a873e78d2191836a178a492da";
    "inference.yml" = "sha256:193f435274bf9f0b5f71a929bbfbcf148282df7e633b34e7c373e8f44741b516";
  };
  recognition = model "PP-OCRv6_small_rec" "bd619643acac4b9650c040234da8d944476ee3f1" {
    "inference.json" = "sha256:f0bf53c853937a917affdd74467472167727f8ab0f0f7bded01c4a16c27e46e6";
    "inference.pdiparams" = "sha256:406e1e689c9a7fbb04178007a3fe10cf852afe7bf8bb3bc6dbb9d532b13bd907";
    "inference.yml" = "sha256:ab078671bb49f06228eadccd34f1bb501e157f7a047095ffb943ba81512c77d1";
  };
  command = writeShellApplication {
    name = "ocr-cpu";
    text = ''
      export PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK=True
      export OMP_NUM_THREADS=4
      exec ${runtime}/bin/python ${./ocr_cpu.py} \
        --detection-model ${detection} --recognition-model ${recognition} "$@"
    '';
    passthru.tests.offline = runCommand "ocr-cpu-offline-smoke" {} ''
            export PADDLE_PDX_CACHE_HOME="$TMPDIR/paddle"
            export XDG_CACHE_HOME="$TMPDIR/cache"
            ${runtime}/bin/python - <<'PYTEST'
      from PIL import Image, ImageDraw, ImageFont
      image = Image.new("RGB", (1200, 220), "white")
      font = ImageFont.truetype("${dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf", 40)
      ImageDraw.Draw(image).text((30, 50), "Documento di prova 2026: totale euro 1.234,56", font=font, fill="black")
      image.save("prova.png")
      PYTEST
            ${command}/bin/ocr-cpu prova.png --json risultato.json > testo.txt
            ${runtime}/bin/python - <<'PYTEST'
      import json
      from pathlib import Path
      text = Path("testo.txt").read_text()
      assert "1.234,56" in text, text
      assert "2026" in text, text
      result = json.loads(Path("risultato.json").read_text())
      assert result["device"] == "cpu"
      assert len(result["pages"]) == 1
      assert len(result["pages"][0]["scores"]) == len(result["pages"][0]["texts"])
      PYTEST
            printf '%s' '%PDF-1.4' > documento.pdf
      if ${command}/bin/ocr-cpu documento.pdf > inatteso.txt 2> errore.txt; then
        echo "un PDF non deve essere trattato come una singola immagine" >&2
        exit 1
      fi
      grep -q "immagine non valida" errore.txt
      touch "$out"
    '';
    meta.description = "OCR locale PP-OCRv6 small su CPU, con modelli fissati";
  };
in
  command
