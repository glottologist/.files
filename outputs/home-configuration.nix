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

  redtailConf = import ../systems/redtail/home/configuration.nix {
    inherit nur pkgs;
    inherit (pkgs) config lib stdenv;
  };

  bebopConf = import ../systems/bebop/home/configuration.nix {
    inherit nur pkgs;
    inherit (pkgs) config lib stdenv;
  };

  swordfishConf = import ../systems/swordfish/home/configuration.nix {
    inherit nur pkgs;
    inherit (pkgs) config lib stdenv;
  };
in
{
  home-redtail   = mkHome redtailConf;
  home-bebop     = mkHome bebopConf;
  home-swordfish = mkHome swordfishConf;
}
