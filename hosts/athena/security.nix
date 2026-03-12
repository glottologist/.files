{
  config,
  lib,
  pkgs,
  ...
}: {
  security = {
    sudo.wheelNeedsPassword = true;
    polkit.enable = true;
  };
}
