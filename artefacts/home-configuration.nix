{
  inputs,
  system,
  nixpkgs,
  home-manager,
  ...
}:
with inputs; let
  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;

    overlays = [
    ];
  };

  hyprland = inputs.hyprland;

  imports = [
    ../homes/jason/home.nix
  ];

  mkHome = {user ? "jason"}: (
    home-manager.lib.homeManagerConfiguration rec {
      inherit pkgs;

      modules = [
        {inherit imports;}
        hyprland.homeManagerModules.default
      ];
    }
  );
in {
  jason = mkHome {user = "jason";};
  valiant = mkHome {user = "valiant";};
}
