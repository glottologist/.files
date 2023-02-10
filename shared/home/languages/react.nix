{ pkgs, ...}:
{
  home.packages = with pkgs; [
  nodePackages.react-tools
  nodePackages.create_react_app

];

  home.sessionVariables = {
    PATH = ["$HOME/.npm-packages/bin"];
  };

}
