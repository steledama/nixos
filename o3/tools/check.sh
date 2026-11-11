#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

if [[ "${1:-}" == "--flake" ]]; then
  run_flake_check=1
else
  run_flake_check="${RUN_FLAKE_CHECK:-0}"
fi

echo "==> Nix formatting"
alejandra --check .

echo "==> KB structural audit"
python3 o3/tools/kb_tools.py audit --format markdown

echo "==> KB facts"
python3 o3/tools/kb_tools.py facts

echo "==> KB coverage"
python3 o3/tools/kb_tools.py coverage

echo "==> KB fidelity"
python3 o3/tools/kb_tools.py fidelity

if [[ "$run_flake_check" == "1" ]]; then
  echo "==> Flake check"
  nix flake check
else
  echo "==> Skipping nix flake check (run o3/tools/check.sh --flake or RUN_FLAKE_CHECK=1 o3/tools/check.sh)"
fi
