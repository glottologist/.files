{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (pkgs.callPackage ./aether.nix {})
    wpaperd
    swaybg
    hyprpaper
    fondo
    mpvpaper
  ];
}
