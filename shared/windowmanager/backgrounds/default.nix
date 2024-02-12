{pkgs, ...}: {
  home.packages = with pkgs; [
    wpaperd
    swaybg
    hyprpaper
    fondo
    mpvpaper
  ];
}
