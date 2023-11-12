{pkgs, ...}: {
  home.packages = with pkgs; [
    nodePackages.coc-python # python extension for coc
    virtualenv
    python311Full
    python311Packages.pandas
    python311Packages.jupyter
    python311Packages.jupyterlab
    python311Packages.jupyterlab_server
    python311Packages.jupyterlab_widgets
    python311Packages.jupyterlab_launcher
    python311Packages.jupyterlab_lsp
    python311Packages.numpy
    python311Packages.pandas
    python311Packages.pdf2image
    python311Packages.pelican
    python311Packages.pip
    python311Packages.pylru
    python311Packages.pynvim
    python311Packages.setuptools
    python311Packages.tomlkit
  ];
}
