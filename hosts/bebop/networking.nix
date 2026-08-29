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
        # LAN split-horizon: skip hairpin NAT for the Headscale hostname.
        "${hosts.mantis} hs.glottologist.co.uk"
      ]
    );
  };

  # Plain DNS to Quad9 (DoT off — opportunistic DoT stalled dig/musl on this link).
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "allow-downgrade";
      Domains = [ "~." ];
      FallbackDNS = [
        "9.9.9.9"
        "149.112.112.112"
      ];
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

# Nix guideline compliant 2026-08-26
