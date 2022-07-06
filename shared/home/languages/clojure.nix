{ pkgs, ...}:
{
  home.packages = with pkgs; [
   (clojure.override { jdk = jdk11; })
    clojure-lsp
    babashka
    clj-kondo
    (leiningen.override { jdk = jdk11; })
  ];
}
