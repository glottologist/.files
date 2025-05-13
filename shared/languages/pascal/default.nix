{pkgs, ...}: {
  home.packages = with pkgs; [
  fpc
  lazarus
  ];
}
