{ system, nixpkgs,  home-manager, tex2nix,  ... }:

let
  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;

  };


  mkHome = {user ? "jason"}: (
    home-manager.lib.homeManagerConfiguration rec {
      inherit pkgs;

      imports = [
         ../homes/${user}/home.nix
      ];

      modules = [{inherit imports;}];
    });
in
{
  jason   = mkHome { user = "jason"; };
  valint   = mkHome { user = "valiant"; };

}
