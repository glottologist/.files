{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    comical
    dosage
    mcomix
    peruse
    cbconvert
    cbconvert-gui
    qcomicbook
    kcc
  ];
}
