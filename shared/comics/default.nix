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
    qcomicbook
    kcc
  ];
}
