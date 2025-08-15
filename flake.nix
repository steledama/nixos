# nixos/flake.nix
{
  description = "Nixos config flake";
  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixvim
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    # Secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    agenix,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    # Base modules for all hosts (minimal)
    baseModules = [
      home-manager.nixosModules.home-manager
      agenix.nixosModules.default
      
      ./modules/system/common.nix
    ];


    # Helper function for all hosts
    mkHost = hostname:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/${hostname}
        ] ++ baseModules;
      };
  in {
    nixosConfigurations = {
      pc-game = mkHost "pc-game";
      srv-norvegia = mkHost "srv-norvegia";
      pc-minibook = mkHost "pc-minibook";
      pc-sviluppo = mkHost "pc-sviluppo";
    };
  };
}
