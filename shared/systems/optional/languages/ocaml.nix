{ pkgs, ...}:
{
  environment.systemPackages = with pkgs;
    with ocamlPackages; [
      ocaml
      ocaml-lsp
      ocamlformat
      odoc
      ocaml
      dune_3
  ];
}
