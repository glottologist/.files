{pkgs, ...}: {
  home.packages = with pkgs; [
    shellcheck
    bashate
    beautysh
  ];
}
