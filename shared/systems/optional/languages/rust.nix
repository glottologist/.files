# configuration.nix
{ config, pkgs, ... }:
{
  nixpkgs.config.packageOverrides = pkgs: {
    rustNightly = pkgs.callPackage ./rust/rust-nightly.nix {};
  };

  environment.systemPackages = with pkgs; [
    #(nixpkgs.latest.rustChannels.nightly.rust.override { extensions = [ "rust-src" "rls-preview" "rustfmt-preview" "clippy-preview" ];})
    rustc
    rustup
    rust-analyzer
    crate2nix
    cargo
    cargo-asm
    cargo-deps
    cargo-expand
    cargo-geiger
    cargo-inspect
    cargo-release
    cargo-tarpaulin
  ];

  environment.variables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    RUSTUP_TOOCHAIN = "stable";
    PATH = ["$HOME/.cargo/bin"];
  };

}
