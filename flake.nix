{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      # system configurations
      nixosConfigurations = {
        pcgame = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/pcgame.nix
          ];
        };
        acquisti-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/acquisti-laptop.nix
          ];
        };
        sviluppo-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/sviluppo-laptop.nix
          ];
        };
      };
      # HOME-MANAGER as standalone
      # homeConfigurations =
      # {
      #   user = home-manager.lib.homeManagerConfiguration {
      #     specialArgs = { inherit inputs; };
      #     modules = [
      #       ./users/stefano.nix
      #     ];
      #   };
      # };
    };
}
