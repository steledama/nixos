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

    # niri
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zen browser
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    niri,
    zen-browser,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    overlays = [
      niri.overlays.niri
    ];

    # Base modules for all hosts
    baseModules = [
      home-manager.nixosModules.home-manager
      # Include the Niri NixOS module
      niri.nixosModules.niri
      {
        nixpkgs.overlays =
          overlays
          ++ [
            # Add zen-browser to pkgs
            (final: prev: {
              zen-browser = zen-browser.packages.${system}.default;
            })
          ];
        nixpkgs.config.allowUnfree = true;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "";
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
      srv-norvegia = mkHost "srv-norvegia" [];
      minibook = mkHost "minibook" [];
      pc-sviluppo = mkHost "pc-sviluppo" [];
    };
  };
}
