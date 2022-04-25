{ system, nixpkgs,  home-manager, tex2nix, ... }:

let
  username = "jason";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;
    config.xdg.configHome = configHome;

    #overlays = [
      #nurpkgs.overlay
      #(f: p: { tex2nix = tex2nix.defaultPackage.${system}; })
    #];
  };

  #nur = import nurpkgs {
    #inherit pkgs;
    #nurpkgs = pkgs;
  #};

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
in
{
  jason   = mkHome jasonConf;
}
