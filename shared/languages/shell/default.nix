{pkgs, ...}: {
  home.packages = with pkgs; [
    bashate
    beautysh
     (pkgs.bats.withLibraries (p: [ p.bats-assert p.bats-file p.bats-support ]))
      nodePackages.bash-language-server
      shellcheck
      shfmt
  ];
}
