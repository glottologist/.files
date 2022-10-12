{ config, pkgs, ... }:

{
  imports =
    [
      ./coq.nix
      ./clojure.nix
      ./elixir.nix
      ./elm.nix
      ./fsharp.nix
      ./fstar.nix
      ./general.nix
      ./go.nix
      ./haskell.nix
      ./idris.nix
      ./julia.nix
      ./latex.nix
      ./nim.nix
      ./nix.nix
      ./node.nix
      ./ocaml.nix
      ./purescript.nix
      #./python.nix
      ./rust.nix
      ./scala.nix
      ./terraform.nix
      ./typescript.nix
    ];
}

