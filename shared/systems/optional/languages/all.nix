{ config, pkgs, ... }:

{
  imports =
    [
      ./ada.nix
      ./clojure.nix
      ./elixir.nix
      ./elm.nix
      ./fsharp.nix
      ./fstar.nix
      ./go.nix
      ./haskell.nix
      #./julia.nix
      ./latex.nix
      ./nim.nix
      ./nix.nix
      ./ocaml.nix
      ./purescript.nix
      ./python.nix
      ./rust.nix
      ./scala.nix
      ./solidity.nix
      ./terraform.nix
      ./typescript.nix
    ];
}

