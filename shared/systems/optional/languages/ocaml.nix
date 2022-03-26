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
      nodePackages.ocaml-language-server
  ];
}
