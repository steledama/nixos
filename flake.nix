# nixos/flake.nix

{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Input per la configurazione di Neovim
    neovim-config = {
      url = "github:steledama/neovim-config";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Helper function to create host configurations
      mkHost =
        hostname: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostname}
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = {
                neovim-config = inputs.neovim-config;
              };
            }
          ] ++ extraModules;
        };
    in
    {
      # Host configurations
      nixosConfigurations = {
        pcgame = mkHost "pcgame" [ ];
        acquisti-laptop = mkHost "acquisti-laptop" [ ];
        sviluppo-laptop = mkHost "sviluppo-laptop" [ ];
      };
    };
}
