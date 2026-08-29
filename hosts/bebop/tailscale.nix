{
  # Headscale client. Control plane is Caddy → Headscale on mantis.
  # Create a reusable preauth key on mantis, then write it on bebop:
  #   ssh mantis -- sudo headscale preauthkeys create --user 1 --reusable --expiration 90d
  #   sudo install -m 600 /dev/null /etc/headscale/bebop.preauth
  #   sudo tee /etc/headscale/bebop.preauth >/dev/null <<<'<KEY>'
  # Do not put the key in this file (it would copy into the Nix store).
  services.tailscale = {
    enable = true;
    authKeyFile = "/etc/headscale/bebop.preauth";
    extraUpFlags = [
      "--login-server=https://hs.glottologist.co.uk"
    ];
    openFirewall = true;
  };
}
