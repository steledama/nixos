# modules/system/nix.nix
{
  inputs,
  pkgs,
  ...
}: {
  # Protezione software proprietario: blocca installazioni accidentali
  nixpkgs.config.allowUnfree = false;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      # Keep build dependencies and outputs in the nix store
      # This improves development experience by keeping intermediary build files
      # and helps with debugging builds
      keep-outputs = true;
      keep-derivations = true;
      # Download buffer size to 100MB (default is 16MB)
      download-buffer-size = 100 * 1024 * 1024;
      # Binary cache configuration
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      # Set nixpkgs path to match the one from flake inputs
      # This ensures consistency between flake and non-flake commands
      nix-path = ["nixpkgs=${inputs.nixpkgs}"];
    };
    # garbage collection automation
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Configuration to limit coredumps
  systemd.coredump = {
    enable = true;
    settings.Coredump = {
      Storage = "none";
      ProcessSizeMax = 0;
    };
  };

  # Enable nix-ld to run dynamic binaries (e.g., OpenCode, VSCode extensions)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      curl
      # Add common libraries needed by dynamic binaries
    ];
  };

  # Formatters and language servers moved to modules/home/dev-tools.nix
  # This enables faster user-space updates without sudo (~10s vs ~2min)
}
