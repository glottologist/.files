{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    comical
    peruse
    cbconvert
    cbconvert-gui
    qcomicbook
    kcc
  ];
}
