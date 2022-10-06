{ lib, inputs, system, nixpkgs, ... }:
let
  nixosSystem = inputs.nixpkgs.lib.nixosSystem;
in
{

  redtail = nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../systems/redtail/configuration.nix
    ];
  };


  bebop = nixosSystem {
    inherit system;
    specialArgs = { inherit inputs;  };
    modules = [
      ../systems/bebop/configuration.nix
    ];
  };


  swordfish = nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../systems/swordfish/configuration.nix
    ];
  };

  valkyrie = nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../systems/valkyrie/configuration.nix
    ];
  };

}
