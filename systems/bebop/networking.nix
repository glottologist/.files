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
    wg-quick.interfaces = {
      rtwg0 = {
       privateKeyFile = "/etc/wireguard/private.key";
       address =[ "10.75.13.3/32" ];
       listenPort = 48232;
       peers = [
        {
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "148.113.12.147:48232";
          publicKey = "WeeJVyAPczoANEsuOJEHOotroxRyCRXREui96GgXhio=";
        }
      ];
    };
  };
};
}
