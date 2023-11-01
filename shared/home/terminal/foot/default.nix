{
  config,
  pkgs,
  lib,
  ...
}:
 {
  home.packages = with pkgs; [
  ];
  programs.foot.enable = true;
  xdg.configFile."foot/foot.ini".text = builtins.readFile ./foot.ini;
}

