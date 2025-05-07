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
}
