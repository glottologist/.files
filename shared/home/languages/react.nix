{ pkgs, ...}:
{
  home.packages = with pkgs; [
  nodePackages.react-tools
  nodePackages.create-react-app

];


}
