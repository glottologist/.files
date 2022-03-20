{ lib, inputs, system, ... }:
{

  redtail = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../shared/systems/configuration.nix
      ../systems/redtail/configuration.nix
    ];
  };


  bebop = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../shared/systems/configuration.nix
      ../systems/bebop/configuration.nix
    ];
  };


  swordfish = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../shared/systems/configuration.nix
      ../systems/swordfish/configuration.nix
    ];
  };

  valkyrie = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../shared/systems/configuration.nix
      ../systems/valkyrie/configuration.nix
    ];
  };

}
