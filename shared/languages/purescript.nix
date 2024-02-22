{ pkgs, ...}:
{
  home.packages = with pkgs; [
    nodePackages.purescript-language-server # Language Server Protocol server for PureScript wrapping purs ide server functionality
  ];

}
