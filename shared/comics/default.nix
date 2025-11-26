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
    #cbconvert # Broken - Go type mismatch in go-fitz
    #cbconvert-gui # Broken - depends on cbconvert
    qcomicbook
    kcc
    komga # Free and open source comics/mangas server
  ];
}
