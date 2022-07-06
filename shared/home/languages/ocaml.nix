{ pkgs, ...}:
{
  home.packages = with pkgs; [
      ocaml
      ocamlformat
      opam
      ocamlPackages.odoc
      ocaml
      dune_3
      ligo
      ocamlPackages.merlin
      ocamlPackages.data-encoding
      ocamlPackages.ocp-indent
      ocamlPackages.ocaml-lsp
      # Only required for Tezos development
      libev
      libffi
      pkg-config
    ];
}
