# configuration.nix
{ config, pkgs, ... }:
{
  nixpkgs.config.packageOverrides = pkgs: {
    rustNightly = pkgs.callPackage ./rust/rust-nightly.nix {};
  };

  home.packages = with pkgs; [
    #(nixpkgs.latest.rustChannels.nightly.rust.override { extensions = [ "rust-src" "rls-preview" "rustfmt-preview" "clippy-preview" ];})
    #rustc
    rustup
    rust-analyzer
    crate2nix
  ];

  home.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    RUSTUP_TOOCHAIN = "stable";
    #PATH = ["$HOME/.cargo/bin"];
  };

}
