{ inputs, ... }:

{
  # Optimization settings
  nix = {
    settings = {
      # enable flakes
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
    # Set nixpkgs path to match the one from flake inputs
    # This ensures consistency between flake and non-flake commands
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    # garbage collection automation
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}

