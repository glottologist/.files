{
  description = "Dotfiles configurations for multiple machines NixOS and Home-Manager configurations";

  nixConfig.extra-experimental-features = "nix-command flakes";

  inputs = {
    nixpkgs.url = "github:glottologist/nixpkgs/release-23.11";
    #nixpkgs.url = "github:glottologist/nixpkgs/master";
    home-manager = {
      url = "github:glottologist/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix = {
      url = "github:nixos/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    hyprland,
    agenix,
    nix,
  } @ inputs: let
    system = "x86_64-linux";
  in {
    inherit inputs;

    homeConfigurations = (
      import ./artefacts/home-configuration.nix {
        inherit inputs system nixpkgs home-manager nix;
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
