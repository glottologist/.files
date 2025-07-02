{
  description = "Dotfiles configurations for multiple machines NixOS and Home-Manager configurations";

  nixConfig.extra-experimental-features = "nix-command flakes";

  inputs = {
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/release-25.05";
    nixpkgs.url = "github:glottologist/nixpkgs/release-25.05";
    home-manager = {
      url = "github:glottologist/home-manager/release-25.05";
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
    nixpkgs,
    stylix,
    home-manager,
    hyprland,
    agenix,
    foundry,
    nix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    useHyprland = builtins.getEnv "ENABLE_HYPRLAND" == "0";
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
        stylix.homeModules.stylix
        ./homes/jason.nix];
      };
    };

    nixosConfigurations = {
      "bebop" = nixosSystem {
        inherit pkgs;
        inherit system;
        specialArgs = {
          inherit useHyprland;
        };
        modules = [
          stylix.nixosModules.stylix
          ./hosts/bebop/configuration.nix
        ];
      };
    };
  };
}
