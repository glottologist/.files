{lib, ...}: {
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

  # The generated autoconnect unit is Type=notify and only reports ready
  # once Tailscale reaches Running; with the Headscale server unreachable
  # it times out after 90s and fails every boot and every
  # `nixos-rebuild switch` (exit status 4). Replace it with a plain
  # background loop: the switch no longer waits on it, and it retries
  # until the control plane is reachable.
  systemd.services.tailscaled-autoconnect = {
    serviceConfig.Type = lib.mkForce "exec";
    script = lib.mkForce ''
      while :; do
        state="$(tailscale status --json --peers=false | jq -r '.BackendState')" || state=""
        case "$state" in
          Running)
            echo "Tailscale is running"
            exit 0
            ;;
          NeedsLogin | NeedsMachineAuth | Stopped)
            echo "Server needs authentication, sending auth key"
            tailscale up --auth-key "$(cat /etc/headscale/bebop.preauth)" \
              '--login-server=https://hs.glottologist.co.uk' || true
            ;;
        esac
        sleep 30
      done
    '';
  };
}
