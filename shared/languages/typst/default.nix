{pkgs, ...}: {
  home.packages = with pkgs; [
  typst
  tinymist # lsp
   typstyle # formatter

  ];
}
