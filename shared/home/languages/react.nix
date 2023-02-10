{ pkgs, ...}:
{
  home.packages = with pkgs; [
  nodePackages.react-tools
  nodePackages.create-react-app

];

  home.sessionVariables = {
    PATH = ["$HOME/.npm-packages/bin"];
  };

}
