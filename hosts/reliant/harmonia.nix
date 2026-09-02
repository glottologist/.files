# Reliant serves its /nix/store as a binary cache over Harmonia, so that Bebop
# and the other tailnet hosts can pull what Reliant has already built rather
# than rebuilding it. Harmonia serves the store in place, so this costs no
# additional storage.
#
# The cache is reachable on the tailnet and nowhere else, and that restriction
# is not optional here. Harmonia serves any store path whose hash is presented
# to it, and this host's store contains the home-manager generation that carries
# the OpenAI, Grok and Anthropic keys. A publicly reachable cache would turn a
# local secret-exposure trade-off into a remote one. As with XRDP, the rule is
# expressed against tailscale0 rather than as a bind address, because the tailnet
# address is assigned by Headscale at runtime.
#
# Nginx fronts Harmonia, per upstream's recommendation: it terminates the
# connections, caches narinfo lookups — which dominate a cache's request mix —
# and keeps Harmonia itself on loopback.
#
# The signing key is generated on the host after installation and never enters
# the flake or the Nix store. See hosts/reliant/README.md.
{ ... }:
let
  harmoniaPort = 5001;
  cachePort = 5000;
in
{
  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ "/var/lib/harmonia/cache-priv-key.pem" ];
    settings.bind = "127.0.0.1:${toString harmoniaPort}";
    # Below cache.nixos.org, so clients prefer upstream for anything both hold.
    settings.priority = 50;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;

    # Narinfo lookups are small, numerous and highly repetitive; caching them
    # is what makes fronting Harmonia worthwhile.
    proxyCachePath."harmonia" = {
      enable = true;
      keysZoneName = "harmonia";
      maxSize = "2g";
    };

    virtualHosts."harmonia" = {
      default = true;
      listen = [
        {
          addr = "0.0.0.0";
          port = cachePort;
        }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString harmoniaPort}";
        # Compression is Harmonia's job — it serves NARs zstd-compressed — so
        # nginx only proxies and caches.
        extraConfig = ''
          proxy_cache harmonia;
          proxy_cache_valid 200 10m;
          proxy_cache_valid 404 1m;
        '';
      };
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ cachePort ];
}
