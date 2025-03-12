{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./bash.nix
    ./clojure.nix
    ./elixir.nix
    ./elm.nix
    ./fsharp.nix
    ./go.nix
    ./haskell.nix
    ./kotlin.nix
    ./latex.nix
    ./markdown.nix
    ./nix.nix
    #./node.nix
    ./ocaml.nix
    ./purescript.nix
    ./scala.nix
    ./solidity.nix
    ./zk.nix
  ];
}
