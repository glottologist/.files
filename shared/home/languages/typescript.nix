{ pkgs, ...}:
{
  home.packages = with pkgs; [
  nodePackages.typescript

];

  home.sessionVariables = {
    PATH = ["$HOME/.npm-packages/bin"];
  };

}
