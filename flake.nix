{
  description = "Dotfiles configurations for multiple machines NixOS and Home-Manager configurations";


  inputs = {
    nixpkgs.url = "github:glottologist/nixpkgs/master";
    home-manager = {
      url = github:nix-community/home-manager;
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

  };


  outputs = inputs @ { self, nixpkgs,  home-manager, tex2nix, nix }:
    let
      system = "x86_64-linux";
    in
    {
      inherit inputs;

      homeConfigurations = (
        import ./artefacts/home-configuration.nix {
          inherit system nixpkgs home-manager tex2nix nix;
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
          inherit system nixpkgs nix;
        }
      );
    };


}
