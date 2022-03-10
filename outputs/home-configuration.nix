{ system, nixpkgs, nurpkgs, home-manager, tex2nix, ... }:

let
  username = "jason";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;
    config.xdg.configHome = configHome;

    overlays = [
      nurpkgs.overlay
      (f: p: { tex2nix = tex2nix.defaultPackage.${system}; })
    ];
  };

  nur = import nurpkgs {
    inherit pkgs;
    nurpkgs = pkgs;
  };

  mkHome = conf: (
    home-manager.lib.homeManagerConfiguration rec {
      inherit pkgs system username homeDirectory;

      stateVersion = "21.11";
      configuration = conf;
    });

   shared = import ../shared/home/home.nix {
    inherit nur pkgs;
    inherit (pkgs) config lib stdenv;
   };

  redtailConf = import ../systems/redtail/home/home.nix {
    inherit nur pkgs;
    inherit (pkgs) shared config lib stdenv;
  };

  bebopConf = import ../systems/bebop/home/home.nix {
    inherit nur pkgs;
    inherit (pkgs) shared config lib stdenv;
  };

  swordfishConf = import ../systems/swordfish/home/home.nix {
    inherit nur pkgs;
    inherit (pkgs) shared config lib stdenv;
  };
in
{
  redtail   = mkHome redtailConf;
  bebop     = mkHome bebopConf;
  swordfish = mkHome swordfishConf;
}
