{
  description = "Dotfiles configurations for multiple machines NixOS and Home-Manager configurations";


  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tex2nix = {
      url = github:Mic92/tex2nix/4b17bc0;
      inputs.utils.follows = "nixpkgs";
    };

  };


  outputs = inputs @ { self, nixpkgs,  home-manager, tex2nix }:
    let
      system = "x86_64-linux";
    in
    {
      homeConfigurations = (
        import ./artefacts/home-configuration.nix {
          inherit system nixpkgs home-manager tex2nix;
        }
      );

      nixosConfigurations = (
        import ./artefacts/nixos-configuration.nix {
          inherit (nixpkgs) lib;
          inherit inputs system nixpkgs ;
        }
      );

      devShell.${system} = (
        import ./artefacts/installation.nix {
          inherit system nixpkgs;
        }
      );
    };


}
