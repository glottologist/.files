{ system, nixpkgs,  home-manager, tex2nix,  ... }:

let
  username = "jason";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;
    config.xdg.configHome = configHome;

  };


  mkHome = conf: (
    home-manager.lib.homeManagerConfiguration rec {
      inherit pkgs system username homeDirectory;

      stateVersion = "22.05";
      configuration = conf;
    });


  jasonConf = import ../homes/jason/home.nix {
    inherit pkgs;
    inherit (pkgs) config lib stdenv;
  };
  jasonlightConf = import ../homes/jason-light/home.nix {
    inherit pkgs;
    inherit (pkgs) config lib stdenv;
  };
in
{
  jason   = mkHome jasonConf;
  jasonlight = mkHome jasonlightConf;
}
