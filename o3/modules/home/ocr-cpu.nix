# Riserva OCR locale su CPU per deck; nessun servizio o download al runtime.
{pkgs, ...}: {
  home.packages = [(pkgs.callPackage ./ocr-cpu/package.nix {})];
}
