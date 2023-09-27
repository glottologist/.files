{
  description = "Dotfiles configurations for multiple machines NixOS and Home-Manager configurations";

  nixConfig.extra-experimental-features = "nix-command flakes";

  inputs = {
    nixpkgs.url = "github:glottologist/nixpkgs/23.05";
    home-manager = {
      url = github:nix-community/home-manager/release-23.05;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tex2nix = {
      url = github:Mic92/tex2nix/4b17bc0;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix = {
      url = "github:nixos/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixos-generators.url = "github:nix-community/nixos-generators";

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    agenix.url = "github:ryantm/agenix";

    hyprland.url = "github:hyprwm/Hyprland";

  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    tex2nix,
    deploy,
    nixos-hardware,
    nixos-generators,
    flake-utils-plus,
    fenix,
    nur,
    agenix,
    hyprland,
    nix,
  } @ inputs: let
    system = "x86_64-linux";
  in {
    inherit inputs;

    homeConfigurations = (
      import ./artefacts/home-configuration.nix {
        inherit inputs system nixpkgs home-manager tex2nix nix hyprland;
      }
    );

    nixosConfigurations = (
      import ./artefacts/nixos-configuration.nix {
        inherit (nixpkgs) lib;
        inherit inputs system nixpkgs nix;
      }
    );

    devShell.${system} = (
      import ./artefacts/installation.nix {
        inherit system nixpkgs;
      }
    );
  };
}
