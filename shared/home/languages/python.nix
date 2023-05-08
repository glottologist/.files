{ pkgs, ...}:
{
  home.packages = with pkgs; [
     nodePackages.coc-python                 # python extension for coc
     python310Full
     python310Packages.pandas
     python310Packages.pdf2image
     python310Packages.pelican
     python310Packages.pip
     python310Packages.pylru
     python310Packages.pynvim
     python310Packages.setuptools
     python310Packages.tomlkit
  ];

}
