{ lib, inputs, system, ... }:
{
  redtail = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../shared/nixos/configuration.nix
      ../systems/redtail/nixos/configuration.nix
    ];
  };


  bebop = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../shared/nixos/configuration.nix
      ../systems/bebop/nixos/configuration.nix
    ];
  };


  swordfish = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ../shared/nixos/configuration.nix
      ../systems/swordfish/nixos/configuration.nix
    ];
  };

}
