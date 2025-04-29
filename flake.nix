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
    claude-desktop,
    niri,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    overlays = [
      (import ./overlays/msty.nix)
      # Includi l'overlay di Niri per tutti gli host
      niri.overlays.niri
    ];

    # Moduli di base per tutti gli host
    baseModules = [
      home-manager.nixosModules.home-manager
      # Includi il modulo NixOS di Niri per tutti gli host
      niri.nixosModules.niri
      {
        nixpkgs.overlays = overlays;
        nixpkgs.config.allowUnfree = true;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = {inherit inputs;};

        # Niri è disponibile ma non attivato di default
        # Utilizziamo mkDefault per permettere sovrascritture
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
