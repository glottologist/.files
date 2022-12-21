{ system, nixpkgs,  home-manager, tex2nix,  ... }:

let
  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;

  };

 imports = [
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

}
