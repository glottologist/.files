# Pull from Reliant's Harmonia cache.
#
# Reliant serves its own /nix/store to the tailnet, so any host importing this
# fetches what Reliant has already built instead of rebuilding it. That matters
# most for Defiant, which shares Reliant's configuration almost exactly but has
# a third of the disk and the same 3.7 GiB of RAM.
#
# Reliant is addressed by its tailnet IP rather than by name: the Headscale
# client in ../common/tailscale.nix does not pass --accept-dns, so MagicDNS
# names are not guaranteed to resolve, whereas the address is stable.
#
# Reliant itself must not import this — it would be querying its own store over
# the network.
#
# These lists concatenate with the ones in ../common/nix.nix rather than
# replacing them, so cache.nixos.org and the Cachix caches remain in place.
{ ... }:
{
  nix.settings = {
    substituters = [ "http://100.64.0.6:5000" ];
    trusted-public-keys = [
      "reliant-1:F6fRa30mTFXr7feSebtWwM8CF3yV7BhA09cnRsvu/uM="
    ];
  };
}
