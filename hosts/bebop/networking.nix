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
    networkmanager = {
      enable = true;
      wifi.powersave = false; # Prevent periodic wifi disconnections
    };
    useDHCP = lib.mkDefault true;
    extraHosts = builtins.readFile ../../secrets/hosts;
  };

}
