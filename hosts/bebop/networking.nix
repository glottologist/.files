{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  environment.systemPackages = with pkgs; [networkmanagerapplet];
  networking = {
    hostName = "bebop"; # Define your hostname.
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
    extraHosts = builtins.readFile ../../secrets/hosts;
  };

}
