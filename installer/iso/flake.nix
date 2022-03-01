{
  description = "Flake to package NixOS ISOs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  };

  outputs = { self, nixpkgs }: let

    lib = import ./lib;
    system = "x86_64-linux";

    allPkgs = lib.mkPkgs { inherit nixpkgs; };

    mkIso = {system, cfg ? {}, ...}: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {};

      modules = [
        {
          imports = [ ./modules ];
          nixpkgs.pkgs = allPkgs."${system}";
        }

        cfg
      ];
    };
  in {
    iso = lib.withDefaultSystems (sys: {
      i3 = (mkIso { system = sys; cfg = { iso.wm = "i3"; }; }).config.system.build.isoImage;
    });
  };
}
