{ pkgs, ...}:
{
  environment.systemPackages = with pkgs;
    with ocamlPackages; [
      ocaml
      ocamlformat
      opam
      odoc
      ocaml
      dune_3
      ligo
      merlin
      data-encoding
      ocp-indent
      ocaml-lsp
      # Only required for Tezos development
      libev
      libffi
      pkg-config
  ];
}
