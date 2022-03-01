{ lib, inputs, system, ... }:
{
  redtail = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../systems/redtail/nixos/configuration.nix
    ];
  };


  bebop = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../systems/bebop/nixos/configuration.nix
    ];
  };


  swordfish = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../systems/swordfish/nixos/configuration.nix
    ];
  };

}
