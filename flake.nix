{
  description = "Dotfiles configurations for multiple machines NixOS and Home-Manager configurations";

  nixConfig.extra-experimental-features = "nix-command flakes";

  inputs = {
    nixpkgs.url = "github:glottologist/nixpkgs/release-24.05";
    #nixpkgs.url = "github:glottologist/nixpkgs/master";
    home-manager = {
      #url = "github:glottologist/home-manager/master";
      url = "github:glottologist/home-manager/release-24.05";
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
    pkgs = import nixpkgs {};
  in {
    inherit inputs;
    homeConfigurations = {
      "glottologist" = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./homes/glottologist.nix];
      };
    };
  };
}
