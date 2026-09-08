# Defiant — Hetzner Agent Desktop

Public IP: `65.109.6.50`
Private IP: `10.79.93.3` (Hetzner private network, `enp7s0`)
Hardware: Hetzner Cloud CX22 — 2 Intel vCPU, 3.7 GiB RAM, 38.1 GiB disk
Firmware: legacy BIOS, so the bootloader is GRUB

Defiant runs the agent stack: Ennio's node daemon, Syncthing paired with Bebop,
and a Plasma 6 desktop reachable over RDP through the tailnet. It does not serve
a binary cache — that is Reliant's job — but it should consume Reliant's.

## Installation

Installation erases the whole of `/dev/sda`. Two things on the previous Debian 12
image were deliberately given up when this host was reinstalled: a running
Twingate connector, and 215 MB of clones under `/root/development`, all of which
exist elsewhere.

```bash
nix-everywhere bootstrap --target-host root@65.109.6.50 --flake .#defiant
```

`nix-everywhere` resolves `nixos-anywhere` on `PATH` and delegates to it, so that
binary must be available. The flake must be committed first: the deployment reads
the committed tree, not the working copy.

Unlike Reliant, this host boots in legacy BIOS mode. GRUB installs to the disk
through the 1 MiB `EF02` partition that `hosts/common/hetzner-disk.nix` creates,
and the disk is not named in `hosts/defiant/boot.nix` because disko declares
`boot.loader.grub.devices` itself.

After installation the host key changes:

```bash
ssh-keygen -R 65.109.6.50
ssh root@65.109.6.50 true
ssh jason@65.109.6.50 true
```

## Headscale enrolment

The pre-auth key is never in the flake. Install it root-owned from the unlocked
`home-lab` checkout, then confirm enrolment:

```bash
./scripts/deploy-headscale-preauth defiant   # from the home-lab checkout
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
ssh jason@defiant
passwd
```

## RDP over the tailnet

Connect an RDP client to Defiant's **tailnet** address on port 3389. The public
address will refuse that port, and this is intended rather than a fault:

```bash
# Should refuse — the desktop is not on the public internet.
timeout 5 bash -c 'echo > /dev/tcp/65.109.6.50/3389' \
  && echo "FAIL: publicly reachable" || echo "OK: refused"
```

The restriction is a firewall rule scoped to `tailscale0` rather than a bind
address, because Headscale assigns the tailnet address at runtime and it cannot
be written into the configuration.

## Consuming Reliant's binary cache

Reliant serves its `/nix/store` over Harmonia on the tailnet. Adding it as a
substituter here saves Defiant — the smaller of the two machines — from
rebuilding what Reliant has already built. Take the public key printed by
`cat /var/lib/harmonia/cache-pub-key.pem` on Reliant, then add its tailnet
address as a substituter and that key to `trusted-public-keys`.

## Ennio

`ennio-node` and `grok` are on the system PATH. Ennio on Bebop launches the
daemon over SSH when it connects, passing a token on stdin; there is no
persistent unit, because one holding port 9100 would collide with that
bootstrap and would not share the control plane's token.

```bash
command -v ennio-node grok
grok --version
```

The daemon binds `127.0.0.1:9100` once launched and needs no firewall rule —
SSH is the authentication boundary. It exits after an idle hour on its own.

## Syncthing

The GUI binds loopback only, unlike Corvus and Marauder, because those wildcard
listeners have neither authentication nor TLS and this host has a public address.

```bash
ssh -L 8384:localhost:8384 jason@defiant
# then open http://localhost:8384
curl -s http://localhost:8384/rest/noauth/health
```

## Agent logins

The agent CLIs arrive with the `jason-cloud` home profile, which is applied
separately from the system configuration:

```bash
ssh jason@defiant
cd /path/to/.files && ./do home apply jason-cloud
```

Claude Code authenticates through Max OAuth rather than an API key, so it needs a
browser and therefore a desktop session. Log in from the Plasma session over RDP:

```bash
claude login
codex login
```
