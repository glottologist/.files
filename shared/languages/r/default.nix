{pkgs, ...}: {
  home.packages = with pkgs; [
  R
  radianWrapper
  ];
}
