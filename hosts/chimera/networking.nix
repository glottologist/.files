# Chimera roams, so NetworkManager owns the links and systemd-resolved owns the
# names. The tailnet host names come from secrets/hosts.nix, exactly as they do
# on Bebop, so that `ssh reliant` resolves whether or not MagicDNS is answering.
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
      mosh # SSH that survives the roaming this machine will do
      rsync
      sshfs
      wireguard-tools
      # The mixnet tooling, which is a different thing from NymVPN: it gives a
      # SOCKS5 proxy per application, where hosts/common/nym-vpn.nix gives the
      # device-wide tunnel. Both are wanted.
      nym
    ];
    # Clients use uplink resolvers, not the flaky 127.0.0.53 stub.
    # mkForce: resolved defaults this to stub-resolv.conf.
    etc."resolv.conf".source = lib.mkForce "/run/systemd/resolve/resolv.conf";
  };

  networking = {
    hostName = "chimera";
    networkmanager = {
      enable = true;
      wifi.powersave = true; # A battery-powered machine, unlike Bebop
      dns = "systemd-resolved";
    };
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
    extraHosts = builtins.concatStringsSep "\n" (
      (builtins.attrValues (builtins.mapAttrs (name: ip: "${ip} ${name}") hosts))
      ++ [
        # Control plane is Docker on curunir (public Hetzner IP), not mantis.
        "${hosts.curunir} hs.glottologist.co.uk"
      ]
    );
  };

  # Plain DNS to Quad9, matching Bebop: opportunistic DoT stalled dig and musl
  # on that link, and there is no reason to expect this one to differ.
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

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
}
