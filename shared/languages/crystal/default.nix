{pkgs, ...}: {
  home.packages = with pkgs; [
  crystal
  shards
  ];
}
