{
  lib,
  pkgs,
  ...
}:
let
  hosts = import ../../secrets/hosts.nix;
in
{
  environment = {
    systemPackages = with pkgs; [
      networkmanagerapplet
      nym
      wireguard-tools
    ];
    # Clients use uplink resolvers, not the flaky 127.0.0.53 stub.
    # mkForce: resolved.nix defaults this to stub-resolv.conf.
    etc."resolv.conf".source = lib.mkForce "/run/systemd/resolve/resolv.conf";
  };
  networking = {
    hostName = "bebop"; # Define your hostname.
    networkmanager = {
      enable = true;
      wifi.powersave = false; # Prevent periodic wifi disconnections
      dns = "systemd-resolved";
    };
    useDHCP = lib.mkDefault true;
    extraHosts = builtins.concatStringsSep "\n" (
      (builtins.attrValues (builtins.mapAttrs (name: ip: "${ip} ${name}") hosts))
      ++ [
        # Control plane is Docker on curunir (public Hetzner IP), not mantis.
        "${hosts.curunir} hs.glottologist.co.uk"
      ]
    );
  };

  # Plain DNS to Quad9 (DoT off — opportunistic DoT stalled dig/musl on this link).
  # IPv4 only, and no local DNSSEC validation: on IPv6-enabled guest wifi the
  # v6 path to Quad9 dropped ~1.4 KB signed answers, resolved then degraded that
  # server to no-DO, and with allow-downgrade every .com lookup SERVFAILed for
  # half an hour (2026-09-21, twice). Quad9 validates upstream, so nothing is lost.
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "false";
      Domains = [ "~." ];
      FallbackDNS = [
        "9.9.9.9"
        "149.112.112.112"
      ];
      DNSOverTLS = "no";
      DNS = [
        "9.9.9.9"
        "149.112.112.112"
      ];
    };
  };
}

# Nix guideline compliant 2026-08-26
