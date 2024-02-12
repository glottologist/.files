{ pkgs, ...}:
{
  home.packages = with pkgs; [
      ocaml-top
      ocamlPackages.ocaml
      ocamlPackages.odoc
      ocamlPackages.merlin
      ocamlPackages.data-encoding
      ocamlPackages.dune_3
      ocamlPackages.ocaml-lsp
      ocamlPackages.merlin
      ocamlPackages.utop
      ocamlPackages.odoc
      ocamlPackages.ocp-indent
      ocamlformat
    ];
}
