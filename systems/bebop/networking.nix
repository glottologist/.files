{ config, pkgs, ... }:

{
  networking = {
    hostName = "bebop";
    useDHCP = false;
    interfaces.wlan0.useDHCP = true;
    networkmanager = {
      enable = true;
    };
    nat = {
      enable = true;
      externalInterface = "wlan0";
      internalInterfaces = [ "rtwg0" ];
    };
    firewall = {
      enable = false;
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }
      ];
      allowedTCPPorts = [ 53 17500 48232 51820 ];
      allowedUDPPorts = [ 53 17500 48232 51820 ];
    };
    nameservers = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
    extraHosts = builtins.readFile ../../secrets/hosts;
};
environment.etc.rt-wg0 = {
      target = "wireguard/rt-wg0.conf";
      text = builtins.readFile ../../secrets/rtwg0.conf;
      mode = "0600";
    };

environment.etc.rt-wg0-test = {
      target = "wireguard/rt-wg0-test.conf";
      text = builtins.readFile ../../secrets/rtwg0-test.conf;
      mode = "0600";
    };
}
