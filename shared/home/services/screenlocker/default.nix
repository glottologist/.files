{pkgs, ...}: {
  #settings.lock.bin = "swaylock";

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
  };
}
