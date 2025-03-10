{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  environment.systemPackages = with pkgs; [
      ethtool
      ledger-live-desktop
  ];
}
