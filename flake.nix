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

    # zen browser
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
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
    zen-browser,
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

    # Desktop overlay for zen-browser
    desktopOverlay = {
      nixpkgs.overlays = [ ((import ./overlays/zen-browser.nix) inputs) ];
    };

    # Helper functions for different host types
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
    
    # Desktop host with zen-browser overlay
    mkDesktopHost = hostname: mkHost hostname [desktopOverlay];
    
    # Server host without desktop overlay
    mkServerHost = hostname: mkHost hostname [];
  in {
    nixosConfigurations = {
      pc-game = mkDesktopHost "pc-game"; # Gaming desktop with niri + zen-browser
      srv-norvegia = mkServerHost "srv-norvegia"; # Server without desktop packages
      pc-minibook = mkDesktopHost "pc-minibook"; # Laptop with niri + zen-browser  
      pc-sviluppo = mkDesktopHost "pc-sviluppo"; # Development desktop with GNOME + zen-browser
    };
  };
}
