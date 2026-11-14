# flake.nix
{
  description = "Nixos config flake";
  inputs = {
    # Public examples. Real hosts override this with a local directory;
    # o3/scripts/con-identita.sh requires it and never writes it to the lock.
    identity = {
      url = "path:./o3/identity";
      flake = false;
    };
    # nixpkgs unstable (pinned via flake.lock for stability).
    # Sistemi e home di deck, game e neve: aggiornabile liberamente.
    # Aggiorna con: nix flake update nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # ai: Input separato per agenti AI da aggiornare frequentemente
    # Aggiorna con: nix flake update ai (senza toccare il sistema)
    # Usato per: claude-code, codex, pi-coding-agent, herdr
    ai.url = "github:nixos/nixpkgs/nixos-unstable";

    # nixpkgs-whisper: pin per whisper-cpp (solo host game, NVIDIA). Non è un
    # workaround per una build rotta: è un pacchetto
    # compile-pesante su GPU (build CUDA, potenzialmente ore) che altrimenti
    # ricompilerebbe a ogni bump di `nixpkgs` non correlato (es. i bump di
    # sicurezza di kernel/Docker/Chromium). Cadenza di bump propria, non
    # quella di `nixpkgs` — cfr. skill `manutenzione`, `casa.game.
    # pacchetti_dedicati.whisper-cpp` in i1/manutenzione.json, che registra
    # anche la versione corrente. Aggiornare col bump overlay di
    # `/manutenzione` quando la cadenza dedicata è dovuta.
    nixpkgs-whisper.url = "github:nixos/nixpkgs/f9a75f41be3a74eab55d3a7679d34ad6cc0da977";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    # Identità dell'infrastruttura (domini, IP, chiavi pubbliche, email,
    # endpoint VPN) isolata dalla configurazione strutturale. Vedi o3/identity/.
    identity = import inputs.identity;

    # Shared overlays. Single source of truth: applied both to the outer pkgs
    # used by home-manager standalone configurations and as a nixpkgs.overlays
    # module to every nixosSystem invocation.
    #
    # gogcli: permanent overlay pinning openclaw/gogcli releases (upstream moves
    # faster than nixpkgs). Bumped by /manutenzione (casa branch), not a debt to remove.
    overlays = [
      (final: prev: {
        gogcli = prev.gogcli.overrideAttrs (old: let
          version = "0.48.0";
        in {
          inherit version;
          src = final.fetchFromGitHub {
            owner = "openclaw";
            repo = "gogcli";
            tag = "v${version}";
            hash = "sha256-cfgrXmtjAT/xZtw7FOy67Xx+/3J/N5sS6wf3SOU9pVE=";
          };
          vendorHash = "sha256-4hP6LV8A3P5G+37gAmFI8dREWauXuLMFjeFjkjon4ms=";
          ldflags = [
            "-s"
            "-w"
            "-X github.com/steipete/gogcli/internal/cmd.version=v${version}"
            "-X github.com/steipete/gogcli/internal/cmd.commit=refs/tags/v${version}"
            "-X github.com/steipete/gogcli/internal/cmd.date=1970-01-01T00:00:00Z"
          ];
          passthru =
            (old.passthru or {})
            // {
              tests = {
                version = final.testers.testVersion {
                  package = final.gogcli;
                  command = "gog --version";
                  version = "v${version}";
                };
              };
            };
        });
        # whisper-cpp: vedi input nixpkgs-whisper. Pin di cadenza (non di
        # build rotta): tiene ferma la versione finché non la si bump-a
        # deliberatamente, indipendente dal nixpkgs corrente.
        whisper-cpp =
          (import inputs.nixpkgs-whisper {
            inherit system;
            config.allowUnfree = true;
            config.cudaSupport = true;
          })
          .whisper-cpp;
      })
    ];

    pkgs = import nixpkgs {
      inherit system overlays;
    };

    # Helper function for all hosts.
    mkHost = hostname:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs self identity;};
        modules = [
          ./o3/hosts/${hostname}
          {nixpkgs.overlays = overlays;}
        ];
      };

    # Helper function for home-manager standalone configurations.
    mkHome = {
      username,
      hostname,
    }: let
      # pkgs-ai: nixpkgs separato per agenti AI e relativo multiplexer,
      # aggiornati frequentemente
      # allowUnfree per claude-code (licenza proprietaria Anthropic)
      pkgs-ai = import inputs.ai {
        inherit system;
        config.allowUnfree = true;
      };
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs hostname username pkgs-ai identity;};
        modules = [
          ./o3/home/${username}/${hostname}.nix
        ];
      };
  in {
    packages.${system}.ocr-cpu = pkgs.callPackage ./o3/modules/home/ocr-cpu/package.nix {};

    nixosConfigurations = {
      deck = mkHost "deck";
      game = mkHost "game";
      neve = mkHost "neve";
    };

    homeConfigurations = {
      "stele@deck" = mkHome {
        username = "stele";
        hostname = "deck";
      };
      "stele@game" = mkHome {
        username = "stele";
        hostname = "game";
      };
      "stele@neve" = mkHome {
        username = "stele";
        hostname = "neve";
      };
    };
  };
}
