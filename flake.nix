# nixos/flake.nix
# Updates to ensure correct overlay for niri-unstable
{
  description = "Nixos config flake";
  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixvim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # niri
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    niri,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    overlays = [
      (import ./overlays/msty.nix)
      # Include the Niri overlay for all hosts
      niri.overlays.niri
    ];

    # Base modules for all hosts
    baseModules = [
      home-manager.nixosModules.home-manager
      # Include the Niri NixOS module
      niri.nixosModules.niri
      {
        nixpkgs.overlays = overlays;
        nixpkgs.config.allowUnfree = true;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = {inherit inputs;};

        # Niri is available but not activated by default
        programs.niri.enable = nixpkgs.lib.mkDefault false;
      }
    ];

    mkHost = hostname: extraModules:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules =
          [
            ./hosts/${hostname}
          ]
          ++ baseModules ++ extraModules;
      };
  in {
    nixosConfigurations = {
      pcgame = mkHost "pcgame" [];
      acquisti-laptop = mkHost "acquisti-laptop" [];
      minibook = mkHost "minibook" [];
    };
  };
}
