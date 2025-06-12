{ pkgs, ...}:
{
  home.packages = with pkgs; [
  purescript
    nodePackages.purescript-language-server # Language Server Protocol server for PureScript wrapping purs ide server functionality
      nodePackages.purs-tidy
      purescript-psa
  ];

}
