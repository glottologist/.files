{ pkgs, ...}:
{
  environment.systemPackages = with pkgs;
    with ocamlPackages; [
      ocaml
      ocamlformat
      odoc
      ocaml
      dune_3
      ligo
      merlin
      nodePackages.ocaml-language-server
  ];
}
