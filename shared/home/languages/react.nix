{ pkgs, ...}:
{
  home.packages = with pkgs; [
  nodePackages.create-react-app

];


}
