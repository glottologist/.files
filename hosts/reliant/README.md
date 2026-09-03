# Reliant — Hetzner Agent Desktop

Public IP: `178.104.185.209`
Private IP: `10.79.93.4` (Hetzner private network, `enp7s0`)
Hardware: Hetzner Cloud CPX22 — 2 AMD vCPU, 3.7 GiB RAM, 76.3 GiB disk
Firmware: UEFI, so the bootloader is `systemd-boot`

Reliant runs the agent stack: Ennio's node daemon, Syncthing paired with Bebop,
a Plasma 6 desktop reachable over RDP through the tailnet, and a Harmonia binary
cache serving its own store to the other tailnet hosts.

## Installation

Installation erases the whole of `/dev/sda`. The machine previously ran Debian 13
and held only throwaway clones under `/root/development`.

```bash
nix-everywhere bootstrap --target-host root@178.104.185.209 --flake .#reliant
```

`nix-everywhere` resolves `nixos-anywhere` on `PATH` and delegates to it, so
that binary must be available. The flake must be committed first: the deployment
reads the committed tree, not the working copy.

Reliant's Debian image runs OpenSSH 10, whose per-source penalties reset repeated
connections from the same address. An occasional `Connection reset by peer`
during installation is that mechanism rather than a failure; retry with a pause.

After installation the host key changes:

```bash
ssh-keygen -R 178.104.185.209
ssh root@178.104.185.209 true
ssh jason@178.104.185.209 true
```

## Headscale enrolment

The pre-auth key is never in the flake. Install it root-owned from the unlocked
`home-lab` checkout, then confirm enrolment:

```bash
./scripts/deploy-headscale-preauth reliant   # from the home-lab checkout
ssh reliant 'sudo install -D -o root -g root -m 0600 /dev/stdin /etc/headscale/preauth'
tailscale status
tailscale debug prefs | jq -e '.ControlURL == "https://hs.glottologist.co.uk"'
```

The enrolment unit retries on failure, so the key may be installed after the
first boot without a rebuild.

## Desktop password

XRDP authenticates against the system password, and none is declared in the
flake — deliberately, so that no hash reaches Git or the Nix store. Set one
before expecting RDP to work:

```bash
ssh jason@reliant
passwd
```

## RDP over the tailnet

Connect an RDP client to Reliant's **tailnet** address on port 3389. The public
address will refuse that port, and this is intended rather than a fault:

```bash
# Should refuse — the desktop is not on the public internet.
timeout 5 bash -c 'echo > /dev/tcp/178.104.185.209/3389' \
  && echo "FAIL: publicly reachable" || echo "OK: refused"
```

The restriction is a firewall rule scoped to `tailscale0` rather than a bind
address, because Headscale assigns the tailnet address at runtime and it cannot
be written into the configuration.

## Harmonia binary cache

Reliant serves its own `/nix/store` over HTTP so the other tailnet hosts can pull
what it has already built. Harmonia listens on loopback and nginx fronts it on
port 5000, admitted on `tailscale0` alone.

The cache must stay on the tailnet. Harmonia will serve any store path whose hash
is presented to it, and this host's store contains the home-manager generation
carrying the OpenAI, Grok and Anthropic keys; exposing it publicly would turn a
local secret-exposure trade-off into a remote one.

Generate the signing key once, after installation — it belongs on the host and
never in the flake:

```bash
ssh reliant
sudo mkdir -p /var/lib/harmonia
sudo nix-store --generate-binary-cache-key \
  reliant-1 \
  /var/lib/harmonia/cache-priv-key.pem \
  /var/lib/harmonia/cache-pub-key.pem
sudo chmod 0600 /var/lib/harmonia/cache-priv-key.pem
sudo systemctl restart harmonia
curl -s http://localhost:5000/nix-cache-info
cat /var/lib/harmonia/cache-pub-key.pem
```

To consume the cache from Bebop or another tailnet host, add Reliant's tailnet
address as a substituter and the public key printed above to
`trusted-public-keys` in that host's Nix settings.

## Ennio

The node daemon runs as `jason` and listens on `127.0.0.1:9100`. It is reached
through an SSH tunnel, which is why it needs no firewall rule and carries no
bearer token — SSH is the authentication boundary.

```bash
systemctl status ennio-node
ss -ltn | grep 127.0.0.1:9100
```

It exits after an idle hour by design; `Restart=always` turns that into a
restart rather than an outage.

## Syncthing

The GUI binds loopback only, unlike Corvus and Marauder, because those wildcard
listeners have neither authentication nor TLS and this host has a public address.

```bash
ssh -L 8384:localhost:8384 jason@reliant
# then open http://localhost:8384
curl -s http://localhost:8384/rest/noauth/health
```

## Agent logins

The agent CLIs arrive with the `jason-cloud` home profile, which is applied
separately from the system configuration:

```bash
ssh jason@reliant
cd /path/to/.files && ./do home apply jason-cloud
```

Claude Code authenticates through Max OAuth rather than an API key, so it needs a
browser and therefore a desktop session. Log in from the Plasma session over RDP:

```bash
claude login
codex login
```
