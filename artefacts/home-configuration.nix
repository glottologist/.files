{ inputs, system, nixpkgs,  home-manager, tex2nix,  ... }:

with inputs;

let
  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;

    overlays = [
    ];
  };

 imports = [
   neovim-flake.nixosModules.${system}.hm
   ../homes/jason/home.nix
 ];

  mkHome = {user ? "jason"}: (
    home-manager.lib.homeManagerConfiguration rec {
      inherit pkgs;

      modules = [{inherit imports;}];
    });
in
{
  jason   = mkHome { user = "jason"; };
  valiant   = mkHome { user = "valiant"; };

}
