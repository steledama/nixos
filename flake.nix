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
    # Usato per: claude-code, pi-coding-agent, herdr; codex ha un pin temporaneo
    ai.url = "github:nixos/nixpkgs/nixos-unstable";

    # Temporary Codex 0.166.0 pin: 0.167.0 fails in aws-lc-sys.
    # Remove after the fix for NixOS/nixpkgs#585124 builds on input ai.
    nixpkgs-codex.url = "github:nixos/nixpkgs/f9a75f41be3a74eab55d3a7679d34ad6cc0da977";

    # nixpkgs-whisper: pin per whisper-cpp (solo host game, NVIDIA). Non è un
    # workaround per una build rotta: è un pacchetto
    # compile-pesante su GPU (build CUDA, potenzialmente ore) che altrimenti
    # ricompilerebbe a ogni bump di `nixpkgs` non correlato (es. i bump di
    # sicurezza di kernel/Docker/Chromium). Cadenza di bump propria, non
    # quella di `nixpkgs` — cfr. skill `manutenzione`, `casa.game.
    # pacchetti_dedicati.whisper-cpp`. Pin iniziale = rev correntemente in
    # `nixpkgs` al momento dell'introduzione (whisper-cpp 1.8.7, già in build
    # su game). Aggiornare col bump overlay di `/manutenzione` (passo 8)
    # quando la cadenza dedicata è dovuta.
    nixpkgs-whisper.url = "github:nixos/nixpkgs/8d43d7f8d17371d1fb68f9145bb60858db481275";

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

    # Helper function for all hosts. nixpkgsInput feeds nix.nix (nix-path).
    mkHost = hostname: let
      nixpkgsInput = inputs.nixpkgs;
    in
      nixpkgsInput.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs self nixpkgsInput identity;};
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
        overlays = [
          (_final: _prev: {
            codex = (import inputs.nixpkgs-codex {inherit system;}).codex;
          })
        ];
      };
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs hostname pkgs-ai identity;};
        modules = [
          ./o3/home/${username}/${hostname}.nix
        ];
      };
  in {
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
