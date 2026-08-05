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

  # Plain DNS to Quad9; bypass flaky 127.0.0.53 stub for clients.
  # mkForce: resolved.nix defaults this to stub-resolv.conf.
  environment.etc."resolv.conf".source = lib.mkForce "/run/systemd/resolve/resolv.conf";
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "allow-downgrade";
      Domains = ["~."];
      FallbackDNS = ["9.9.9.9" "149.112.112.112"];
      DNSOverTLS = "no";
      DNS = [
        "9.9.9.9"
        "149.112.112.112"
        "2620:fe::fe"
        "2620:fe::9"
      ];
    };
  };
}
