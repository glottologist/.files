{
  description = "Dotfiles configurations for multiple machines NixOS and Home-Manager configurations";

  nixConfig.extra-experimental-features = "nix-command flakes";

  inputs = {
    #nixpkgs.url = "github:glottologist/nixpkgs/release-24.11";
    nixpkgs.url = "github:glottologist/nixpkgs/release-25.05";
    home-manager = {
      url = "github:glottologist/home-manager/release-25.05";
      #url = "github:glottologist/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix = {
      url = "github:nixos/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    hyprland.url = "github:hyprwm/Hyprland";
    foundry = {
      url = "github:shazow/foundry.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    hyprland,
    agenix,
    foundry,
    nix,
  } @ inputs: let
    pkgs = import nixpkgs {};
  in {
    inherit inputs;
    homeConfigurations = {
      "glottologist" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./homes/glottologist.nix];
      };
      "jason" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./homes/jason.nix];
      };
    };
  };
}
