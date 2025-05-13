{pkgs, ...}: {
  home.packages = with pkgs; [
    circom
    libsnark
  ];
}
