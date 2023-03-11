{ pkgs, ...}:
{
  home.packages = with pkgs; [
     python39
     python39Packages.pandas
     python39Packages.pip
     python39Packages.setuptools
     python39Packages.pdf2image
     python39Packages.tomlkit
     python39Packages.pynvim
     #python39Packages.pyparsing
     python39Packages.pylru
     nodePackages.coc-python                 # python extension for coc
  ];

}
