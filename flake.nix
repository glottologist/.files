{
  description = "Dotfiles configurations for multiple machines NixOS and Home-Manager configurations";

  nixConfig.extra-experimental-features = "nix-command flakes";

  inputs = {
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/release-25.11";
    nixpkgs.url = "github:glottologist/nixpkgs/release-25.11";
    nvim-flake.url = "github:glottologist/nvim-flake";
    neovim-flake.url = "github:glottologist/neovim-flake";
    certora-prover-flake.url = "github:glottologist/certora-prover-flake";
    home-manager = {
      url = "github:glottologist/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix.url = "github:sadjow/claude-code-nix";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    gemini-cli-nix.url = "github:sadjow/gemini-cli-nix";
    llm-agents-nix.url = "github:numtide/llm-agents.nix";




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
    ennio.url = "github:glottologist/ennio";
    nix-everywhere.url = "github:glottologist/nix-everywhere";
    ccstatusline.url = "github:glottologist/ccstatusline-flake";
    foundry = {
      url = "github:shazow/foundry.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    stylix,
    home-manager,
    hyprland,
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
    ennio,
    nix-everywhere,
    ccstatusline,
    nix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config = { allowUnfree = true; permittedInsecurePackages = [ "electron-12.2.3" "electron-13.6.9" "libgit2-0.27.10" "libsoup-2.74.3" "python3.13-youtube-dl-2021.12.17" "qtwebengine-5.15.19" "googleearth-pro-7.3.6.10201" ]; };
    };
    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; permittedInsecurePackages = [ "electron-12.2.3" "electron-13.6.9" "libgit2-0.27.10" "libsoup-2.74.3" "python3.13-youtube-dl-2021.12.17" "qtwebengine-5.15.19" "googleearth-pro-7.3.6.10201" ]; };
      overlays = [
        (final: prev: {
          ollama = pkgs-unstable.ollama;
          ollama-rocm = pkgs-unstable.ollama-rocm;
          ollama-cuda = pkgs-unstable.ollama-cuda;
          ollama-vulkan = pkgs-unstable.ollama-vulkan;
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
          {_module.args = {inherit certora-prover-flake nvim-flake neovim-flake claude-code-nix codex-cli-nix gemini-cli-nix llm-agents-nix ennio nix-everywhere ccstatusline;};}
          stylix.homeModules.stylix
          ./homes/glottologist
        ];
      };
      "jason" = homeManagerConfig {
        inherit pkgs;
        extraSpecialArgs = {
          username = "jason";
        };
        modules = [
          {_module.args = {inherit certora-prover-flake nvim-flake neovim-flake claude-code-nix codex-cli-nix gemini-cli-nix llm-agents-nix ennio nix-everywhere ccstatusline;};}
          stylix.homeModules.stylix
          ./homes/jason.nix
        ];
      };
    };

    nixosConfigurations = {
      "bebop" = nixosSystem {
        inherit pkgs;
        inherit system;
        specialArgs = {
          username = "glottologist";
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
                {_module.args = {inherit certora-prover-flake nvim-flake neovim-flake claude-code-nix codex-cli-nix gemini-cli-nix llm-agents-nix ennio nix-everywhere ccstatusline;};}
                stylix.homeModules.stylix
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
                {_module.args = {inherit certora-prover-flake nvim-flake neovim-flake claude-code-nix codex-cli-nix gemini-cli-nix llm-agents-nix ennio nix-everywhere ccstatusline;};}
                stylix.homeModules.stylix
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
