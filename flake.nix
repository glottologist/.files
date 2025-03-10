{
  description = "Dotfiles configurations for multiple machines NixOS and Home-Manager configurations";

  nixConfig.extra-experimental-features = "nix-command flakes";

  inputs = {
    nixpkgs.url = "github:glottologist/nixpkgs/release-24.11";
    home-manager = {
      url = "github:glottologist/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/release-24.11";
  };

  outputs = {
    nixpkgs,
    stylix,
    ...
  } @ inputs: let
    pkgs = import nixpkgs {};
    useHyprland = builtins.getEnv "ENABLE_HYPRLAND" == "1";
    nixosSystem = inputs.nixpkgs.lib.nixosSystem;
    homeManagerConfig = inputs.home-manager.lib.homeManagerConfiguration;
  in {
    homeConfigurations = {
      "glottologist" = homeManagerConfig {
        inherit pkgs;
        extraSpecialArgs = {
          inherit useHyprland;
        };
        modules = [
          stylix.nixosModules.stylix
        ./homes/glottologist.nix];
      };
      "jason" = homeManagerConfig {
        inherit pkgs;
        extraSpecialArgs = {
          inherit useHyprland;
        };
        modules = [./homes/jason.nix];
      };
    };

    hostConfigurations = {
      "bebop" = nixosSystem {
        inherit pkgs;
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
