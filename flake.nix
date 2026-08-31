{
  description = "Dotfiles configurations for multiple machines NixOS and Home-Manager configurations";

  nixConfig.extra-experimental-features = "nix-command flakes";

  inputs = {
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/release-26.05";
    nixpkgs.url = "github:glottologist/nixpkgs/release-26.05";
    # Pinned revision packaging Linux 7.0.3 — see hosts/bebop/boot.nix.
    nixpkgs-bt-kernel.url = "github:glottologist/nixpkgs/bafb2e8dcc6f2b77a011a13162b478b1074fc575";
    nvim-flake.url = "github:glottologist/nvim-flake";
    neovim-flake.url = "github:glottologist/neovim-flake";
    certora-prover-flake.url = "github:glottologist/certora-prover-flake";
    home-manager = {
      url = "github:glottologist/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix.url = "github:sadjow/claude-code-nix";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    gemini-cli-nix.url = "github:sadjow/gemini-cli-nix";
    llm-agents-nix.url = "github:numtide/llm-agents.nix";
    forgecode.url = "github:tailcallhq/forgecode/7261cdb5e039218a371ea8dd376b55ac2e22e109";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix = {
      url = "github:nixos/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      # Quickshell needs packages newer than the release-26.05 fork carries.
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # Raw Lua Hyprland config vendored by shared/wm/caelestia; not a flake.
    caelestia-dots = {
      url = "github:caelestia-dots/caelestia";
      flake = false;
    };
    # Omarchy 4 "Quattro" quickshell desktop, vendored for the omarchy
    # session; nixified by shared/wm/omarchy/package.nix. Not a flake.
    omarchy = {
      url = "github:omacom/omarchy/v4.0.2";
      flake = false;
    };
    ennio.url = "github:glottologist/ennio";
    nix-everywhere.url = "github:glottologist/nix-everywhere";
    ccstatusline.url = "github:glottologist/ccstatusline-flake";
    foundry = {
      url = "github:shazow/foundry.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # Latest Zen needs ffmpeg_9; 26.05 only has through ffmpeg_8.
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    colibri = {
      url = "github:JustVugg/colibri/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    brickborrow-watch.url = "github:glottologist/brickborrow-watch";
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    stylix,
    home-manager,
    hyprland,
    caelestia-shell,
    caelestia-dots,
    agenix,
    disko,
    foundry,
    nvim-flake,
    neovim-flake,
    certora-prover-flake,
    claude-code-nix,
    codex-cli-nix,
    gemini-cli-nix,
    llm-agents-nix,
    forgecode,
    ennio,
    nix-everywhere,
    ccstatusline,
    nix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = ["electron-12.2.3" "electron-13.6.9" "libgit2-0.27.10" "libsoup-2.74.3" "python3.13-youtube-dl-2021.12.17" "qtwebengine-5.15.19" "googleearth-pro-7.3.7.1155" "python3.12-vllm-0.11.2" "python3.12-pypdf2-3.0.1" "pnpm-10.29.2" "ventoy-1.1.12"];
      };
    };
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = ["electron-12.2.3" "electron-13.6.9" "libgit2-0.27.10" "libsoup-2.74.3" "python3.13-youtube-dl-2021.12.17" "qtwebengine-5.15.19" "googleearth-pro-7.3.7.1155" "python3.12-vllm-0.11.2" "python3.12-pypdf2-3.0.1" "pnpm-10.29.2" "ventoy-1.1.12"];
      };
      overlays = [
        (final: prev: {
          ollama = pkgs-unstable.ollama;
          ollama-rocm = pkgs-unstable.ollama-rocm;
          ollama-cuda = pkgs-unstable.ollama-cuda;
          ollama-vulkan = pkgs-unstable.ollama-vulkan;
          pi-coding-agent = pkgs-unstable.pi-coding-agent;
          colibri = inputs.colibri.packages.${system}.default;
          brickborrow-watch = inputs.brickborrow-watch.packages.${system}.default;
          omarchy-nixified = final.callPackage ./shared/wm/omarchy/package.nix {
            omarchy-src = inputs.omarchy;
          };
          # Sandbox: tests/test_robotstxt.py hits OSError on http://e/somefile.html.
          # pkgs.dosage.doCheck can read false while pytestCheckHook still runs.
          dosage = prev.dosage.overridePythonAttrs (_: {
            doCheck = false;
          });
          # Sandbox: test_invalid_command argparse quotes choice names on 3.13.
          commitizen = prev.commitizen.overridePythonAttrs (_: {
            doCheck = false;
          });
        })
        (final: prev: {
          zen-browser = inputs.zen-browser.packages.${system}.default;
        })
        (final: prev: {
          pythonPackagesExtensions =
            (prev.pythonPackagesExtensions or [])
            ++ [
              (pyfinal: pyprev: {
                jupyter-server = pyprev.jupyter-server.overridePythonAttrs (_: {
                  doCheck = false;
                });
                commitizen = pyprev.commitizen.overridePythonAttrs (_: {
                  doCheck = false;
                });
                # vLLM dep: upstream pins starlette<1.0.0 but 26.05 ships 1.1.0.
                # The cap is a conservative upper bound — relax it so the
                # runtime-deps check passes.
                prometheus-fastapi-instrumentator = pyprev.prometheus-fastapi-instrumentator.overridePythonAttrs (old: {
                  pythonRelaxDeps = (old.pythonRelaxDeps or []) ++ ["starlette"];
                });
              })
            ];
        })
      ];
    };
    nixosSystem = inputs.nixpkgs.lib.nixosSystem;
    homeManagerConfig = inputs.home-manager.lib.homeManagerConfiguration;
  in {
    homeConfigurations = {
      "glottologist" = homeManagerConfig {
        inherit pkgs;
        extraSpecialArgs = {
          username = "glottologist";
        };
        modules = [
          {_module.args = {inherit certora-prover-flake nvim-flake neovim-flake claude-code-nix codex-cli-nix gemini-cli-nix llm-agents-nix forgecode ennio nix-everywhere ccstatusline caelestia-dots;};}
          stylix.homeModules.stylix
          caelestia-shell.homeManagerModules.default
          ./homes/glottologist
        ];
      };
      "jason" = homeManagerConfig {
        inherit pkgs;
        extraSpecialArgs = {
          username = "jason";
        };
        modules = [
          {_module.args = {inherit certora-prover-flake nvim-flake neovim-flake claude-code-nix codex-cli-nix gemini-cli-nix llm-agents-nix forgecode ennio nix-everywhere ccstatusline caelestia-dots;};}
          stylix.homeModules.stylix
          caelestia-shell.homeManagerModules.default
          ./homes/jason
        ];
      };
    };

    nixosConfigurations = {
      "bebop" = nixosSystem {
        inherit pkgs;
        inherit system;
        specialArgs = {
          username = "glottologist";
          # Linux 7.0.3 kernel, pinned for the MT7922 Bluetooth regression.
          btKernelPackages =
            (import inputs.nixpkgs-bt-kernel {
              inherit system;
              config = {allowUnfree = true;};
            }).linuxPackages_latest;
        };
        modules = [
          stylix.nixosModules.stylix
          ./hosts/bebop/configuration.nix
        ];
      };
      "athena" = nixosSystem {
        inherit pkgs;
        inherit system;
        specialArgs = {
          username = "glottologist";
        };
        modules = [
          disko.nixosModules.disko
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              username = "glottologist";
            };
            home-manager.users.glottologist = {
              imports = [
                {_module.args = {inherit certora-prover-flake nvim-flake neovim-flake claude-code-nix codex-cli-nix gemini-cli-nix llm-agents-nix forgecode ennio nix-everywhere ccstatusline caelestia-dots;};}
                stylix.homeModules.stylix
                caelestia-shell.homeManagerModules.default
                ./homes/glottologist
              ];
            };
          }
          ./hosts/athena/configuration.nix
        ];
      };
      "hermes" = nixosSystem {
        inherit pkgs;
        inherit system;
        specialArgs = {
          username = "glottologist";
        };
        modules = [
          disko.nixosModules.disko
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              username = "glottologist";
            };
            home-manager.users.glottologist = {
              imports = [
                {_module.args = {inherit certora-prover-flake nvim-flake neovim-flake claude-code-nix codex-cli-nix gemini-cli-nix llm-agents-nix forgecode ennio nix-everywhere ccstatusline caelestia-dots;};}
                stylix.homeModules.stylix
                caelestia-shell.homeManagerModules.default
                ./homes/glottologist
              ];
            };
          }
          ./hosts/hermes/configuration.nix
        ];
      };
    };
  };
}
