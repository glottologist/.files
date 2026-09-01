{
  config,
  lib,
  ...
}:
let
  cfg = config.services.tailscale;
  controlUrl = "https://hs.glottologist.co.uk";
  authKey = "file:${toString cfg.authKeyFile}";
in
{
  services.tailscale = {
    enable = true;
    authKeyFile = "/etc/headscale/preauth";
    extraUpFlags = [
      "--login-server=${controlUrl}"
      "--timeout=20s"
    ];
    openFirewall = true;
  };

  # Type=notify blocks rebuilds while the control plane is unavailable.
  # This monitor starts immediately and keeps watching for lost login state.
  systemd.services.tailscaled-autoconnect = {
    serviceConfig.Type = lib.mkForce "exec";
    script = lib.mkForce ''
      last_state=""
      while true; do
        state="$(tailscale status --json --peers=false | jq -r '.BackendState')" || state=""
        if [[ "$state" != "$last_state" ]]; then
          echo "State = $state"
          last_state="$state"
        fi

        case "$state" in
          NeedsLogin | NeedsMachineAuth | Stopped)
            echo "Server needs authentication, sending auth key"
            if ! tailscale up \
              --auth-key ${lib.escapeShellArg authKey} \
              ${lib.escapeShellArgs cfg.extraUpFlags}; then
              echo "Authentication failed; retrying in 30 seconds" >&2
            fi
            ;;
        esac

        sleep 30
      done
    '';
  };
}

# Nix guideline compliant 2026-09-01
