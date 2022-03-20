{ lib, inputs, system, ... }:
{

  redtail = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../systems/redtail/configuration.nix
    ];
  };


  bebop = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../systems/bebop/configuration.nix
    ];
  };


  swordfish = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../systems/swordfish/configuration.nix
    ];
  };

  valkyrie = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../systems/valkyrie/configuration.nix
    ];
  };

}
