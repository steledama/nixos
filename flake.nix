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

    # Base modules for all hosts (minimal)
    baseModules = [
      home-manager.nixosModules.home-manager
      {
        nixpkgs.config.allowUnfree = true;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "";
        home-manager.extraSpecialArgs = {inherit inputs;};
      }
    ];

    # Desktop overlay for zen-browser
    desktopOverlay = {
      nixpkgs.overlays = [
        (final: prev: {
          zen-browser = zen-browser.packages.${system}.default;
        })
      ];
    };

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
      pc-game = mkHost "pc-game" [niri.nixosModules.niri desktopOverlay];
      srv-norvegia = mkHost "srv-norvegia" []; # Server - no desktop packages
      pc-minibook = mkHost "pc-minibook" [niri.nixosModules.niri desktopOverlay];
      pc-sviluppo = mkHost "pc-sviluppo" [desktopOverlay]; # Desktop but no niri
    };
  };
}
