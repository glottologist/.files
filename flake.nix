{
  description = "Dotfiles configurations for multiple machines NixOS and Home-Manager configurations";

  nixConfig.extra-experimental-features = "nix-command flakes";

  inputs = {
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/release-25.11";
    nixpkgs.url = "github:glottologist/nixpkgs/release-25.11";
    nvim-flake.url = "github:glottologist/nvim-flake";
    neovim-flake.url = "github:glottologist/neovim-flake";
    home-manager = {
      url = "github:glottologist/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix.url = "github:sadjow/claude-code-nix?rev=fc5359e6ec89edfaaebfbd53780841808f2261b5";

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
    nvim-flake,
    neovim-flake,
    claude-code-nix,
    nix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
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
          {_module.args = {inherit nvim-flake neovim-flake claude-code-nix;};}
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
          {_module.args = {inherit nvim-flake neovim-flake claude-code-nix;};}
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
    };
  };
}
