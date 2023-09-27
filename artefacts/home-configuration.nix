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

  imports = [
    ../homes/jason/home.nix
  ];

  mkHome = {user ? "jason"}: (
    home-manager.lib.homeManagerConfiguration rec {
      inherit pkgs;

      modules = [
        {inherit imports;}
        inputs.hyprland.homeManagerModules.default
        {wayland.windowManager.hyprland.enable = true;}
      ];
    }
  );
in {
  jason = mkHome {user = "jason";};
  valiant = mkHome {user = "valiant";};
}
