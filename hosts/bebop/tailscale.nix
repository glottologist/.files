{
  # Headscale client. Control plane is Caddy → Headscale on mantis.
  # Join after rebuild with a preauth key (do not store the key here):
  #   sudo tailscale up --login-server=https://hs.glottologist.co.uk --auth-key=<KEY>
  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--login-server=https://hs.glottologist.co.uk"
    ];
    openFirewall = true;
  };
}
