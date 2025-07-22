{pkgs, ...}: {
  home.packages = with pkgs; [
    ocaml-ng.ocamlPackages.data-encoding
    ocaml-ng.ocamlPackages.dune_3
    ocaml-ng.ocamlPackages.findlib
    ocaml-ng.ocamlPackages.merlin
    ocaml-ng.ocamlPackages.merlin
    ocaml-ng.ocamlPackages.ocaml
    ocaml-ng.ocamlPackages.ocaml-lsp
    ocaml-ng.ocamlPackages.ocp-indent
    ocaml-ng.ocamlPackages.odoc
    ocaml-ng.ocamlPackages.odoc
    ocaml-ng.ocamlPackages.utop
    ocaml-ng.ocamlPackages.earlybird
    ocaml-top
    ocamlformat
  ];
}
