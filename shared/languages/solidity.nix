{pkgs, ...}: {
  home.packages = with pkgs; [
    slither-analyzer
    solc-select
    bulloak
  ];
}
