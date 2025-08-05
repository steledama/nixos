# nixos/modules/system/nix.nix
{inputs, ...}: {
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
    };
    # Set nixpkgs path to match the one from flake inputs
    # This ensures consistency between flake and non-flake commands
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    # garbage collection automation
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Configuration to limit coredumps
  systemd.coredump = {
    enable = true; # Keep the service enabled
    extraConfig = ''
      Storage=none     # Do not store coredumps
      ProcessSizeMax=0 # Do not process coredumps of any size
    '';
  };
}
