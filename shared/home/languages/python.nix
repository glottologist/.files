{pkgs, ...}: {
  home.packages = with pkgs; [
    #nodePackages.coc-python # python extension for coc
    #black
    #pipenv
    #python311Full
    #python311Packages.ansible-kernel
    #python311Packages.bash_kernel
    #python311Packages.ilua
    #python311Packages.ipykernel
    #python311Packages.jupyter
    #python311Packages.jupyterlab
    #python311Packages.jupyterlab-widgets
    #python311Packages.jupyterlab_server
    #python311Packages.nix-kernel
    python311Packages.numpy
    python311Packages.pandas
    python311Packages.pelican
    python311Packages.pip
    #python311Packages.pynvim
    #python311Packages.setuptools
    #python311Packages.sympy
    #python311Packages.ecpy
    #python311Packages.tomlkit
    #virtualenv
  ];
}
