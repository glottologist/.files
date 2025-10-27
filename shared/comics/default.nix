{
  config,
  pkgs,
  username,
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
    komga # Free and open source comics/mangas server
  ];
}
