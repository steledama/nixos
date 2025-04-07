# nixos/flake.nix
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
    # claude-desktop
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    claude-desktop,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    overlays = [
      (import ./overlays/msty.nix)
    ];

    mkHost = hostname: extraModules:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules =
          [
            ./hosts/${hostname}
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
            }
          ]
          ++ extraModules;
      };
  in {
    nixosConfigurations = {
      pcgame = mkHost "pcgame" [];
      acquisti-laptop = mkHost "acquisti-laptop" [];
    };
  };
}
