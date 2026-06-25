{pkgs,foundry,certora-prover-flake , ...}: {
  home.packages = with pkgs; [
    slither-analyzer
    certora-prover-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
    solc-select
    bulloak
  ];
}
