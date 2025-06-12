{ pkgs, ...}:
{
  home.packages = with pkgs; [
    clojure-lsp
    babashka
    clj-kondo
  ];
}
