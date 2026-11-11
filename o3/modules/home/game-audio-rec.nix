# modules/home/game-audio-rec.nix
# Audio recorder and transcription helpers for stele@game.
{pkgs, ...}: let
  audio-rec = pkgs.writeShellScriptBin "audio-rec" ''
    set -euo pipefail

    target="alsa_input.usb-Blue_Blue_Snowflake-00.mono-fallback"
    output="''${1:-$HOME/audio-rec.wav}"

    case "$output" in
      ~/*) output="$HOME/''${output#~/}" ;;
    esac

    mkdir -p "$(${pkgs.coreutils}/bin/dirname "$output")"

    echo "Recording from Blue Snowflake USB."
    echo "Output: $output"
    echo "Stop with Ctrl+C."

    exec ${pkgs.pipewire}/bin/pw-record \
      --target="$target" \
      --rate=16000 \
      --channels=1 \
      --format=s16 \
      "$output"
  '';
  audio-txt = pkgs.writeShellScriptBin "audio-txt" ''
    set -euo pipefail

    input="''${1:-$HOME/audio-rec.wav}"
    output="''${2:-''${input%.*}.txt}"
    model="$HOME/.local/share/whisper/ggml-large-v3.bin"

    case "$input" in
      ~/*) input="$HOME/''${input#~/}" ;;
    esac
    case "$output" in
      ~/*) output="$HOME/''${output#~/}" ;;
    esac

    if [[ ! -f "$input" ]]; then
      echo "Audio file not found: $input" >&2
      exit 1
    fi

    if [[ ! -f "$model" ]]; then
      echo "Whisper model not found: $model" >&2
      exit 1
    fi

    mkdir -p "$(${pkgs.coreutils}/bin/dirname "$output")"
    out_base="''${output%.*}"

    echo "Transcribing: $input"
    echo "Output: $output"

    /run/current-system/sw/bin/whisper-cli \
      -m "$model" \
      -l it \
      -otxt \
      -of "$out_base" \
      "$input"

    if [[ "$out_base.txt" != "$output" ]]; then
      mv "$out_base.txt" "$output"
    fi
  '';
in {
  home.packages = [
    audio-rec
    audio-txt
  ];

  programs.fish.shellAbbrs = {
    arec = "audio-rec";
    atxt = "audio-txt";
  };
}
