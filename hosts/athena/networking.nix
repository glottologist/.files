{
  config,
  lib,
  pkgs,
  ...
}: let
  hosts = import ../../secrets/hosts.nix;
in {
  networking = {
    hostName = "athena";
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = [22 80 443];
      allowedUDPPorts = [41641];
    };
    extraHosts = builtins.concatStringsSep "\n" (
      builtins.attrValues (builtins.mapAttrs (name: ip: "${ip} ${name}") hosts)
    );
  };

  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    domains = ["~."];
    fallbackDns = ["9.9.9.9" "149.112.112.112"];
    extraConfig = ''
      DNSOverTLS=opportunistic
      DNS=9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net
      [2620:fe::fe]#dns.quad9.net [2620:fe::9]#dns.quad9.net
    '';
  };
}
