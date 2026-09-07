# NymVPN — the nym-vpnd daemon and its client tooling.
#
# The daemon must run as root: it creates the tunnel interface, rewrites the
# routing table and programmes nftables directly over netlink. It listens on a
# Unix socket at /var/run/nym-vpn.sock, and nym-vpnc — the unprivileged CLI —
# drives it from there.
#
# The unit below follows upstream's own (nym-vpn-core/crates/nym-vpnd/.pkg/aur/
# nym-vpnd.service), with the ordering against NetworkManager and resolved that
# upstream specifies, plus the state and log directories the daemon expects.
# The restart limits are upstream's: six attempts in twenty-four seconds, which
# stops a misconfigured account looping indefinitely.
#
# This is a common module rather than a Chimera-specific one so that any host
# in this flake may adopt it without a move.
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.nym-vpn-core ];

  systemd.services.nym-vpnd = {
    description = "NymVPN daemon";
    wants = [ "network-pre.target" ];
    after = [
      "network-pre.target"
      "NetworkManager.service"
      "systemd-resolved.service"
    ];
    wantedBy = [ "multi-user.target" ];

    startLimitBurst = 6;
    startLimitIntervalSec = 24;

    serviceConfig = {
      ExecStart = "${pkgs.nym-vpn-core}/bin/nym-vpnd";
      StateDirectory = "nym-vpnd";
      LogsDirectory = "nym-vpnd";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # The tunnel is WireGuard, and reverse-path filtering drops the returning
  # packets on a link whose route has just been rewritten. "loose" keeps the
  # check's anti-spoofing value while tolerating the asymmetry.
  networking.firewall.checkReversePath = "loose";
}
