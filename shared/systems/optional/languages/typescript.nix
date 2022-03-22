{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
  nodePackages.typescript

];

  environment.variables = {
    PATH = ["$HOME/.npm-packages/bin"];
  };

}
