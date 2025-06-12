{pkgs,foundry, ...}: {
  home.packages = with pkgs; [
    slither-analyzer
    solc-select
    bulloak
  ];
}
