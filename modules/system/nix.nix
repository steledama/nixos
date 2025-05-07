# nixos/modules/system/nix.nix
{ inputs, ... }: {
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

      # Set a temporary directory for builds
      # using a partition with more space
      sandbox-paths = [ "/home/nix-build-tmp=/build" ];
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

    extraOptions = ''
      # Allocate more space for temporary builds
      keep-going = true
      log-lines = 100
    '';
  };

  # Create temporary build directory only if it doesn't already exist
  # This prevents unnecessary permission changes on every activation
  system.activationScripts.nix-build-tmp = ''
    if [ ! -d /home/nix-build-tmp ]; then
      echo "Creating Nix build temporary directory..."
      mkdir -p /home/nix-build-tmp
      chmod 755 /home/nix-build-tmp
    fi
  '';

  # Set the TMPDIR environment variable to point to the new directory
  # This redirects all temporary builds to use this location
  environment.variables = {
    TMPDIR = "/home/nix-build-tmp";
  };
}
