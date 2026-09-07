# Chimera — GPD Pocket 3

Hardware: GPD Pocket 3, Intel Core i7-1195G7 (Tiger Lake), Iris Xe graphics,
an 8″ 1200×1920 OLED on `DSI-1` mounted rotated ninety degrees, NVMe storage.
Firmware: UEFI, so the bootloader is `systemd-boot`.

Chimera is a machine for four things and no others: writing, AI and agents,
reaching the other machines over SSH and the tailnet, and NymVPN. It is not a
portable Bebop, and the absences in `configuration.nix` and `homes/jrt` are
deliberate rather than pending.

The home user is `jrt`, and the profile lives in `homes/jrt` rather than reusing
`homes/jason`, which carries a workstation's breadth this machine has no room
for.

## What handles the hardware

Almost all of it is upstream's work. `nixos-hardware`'s `gpd-pocket-3` module
sets the panel rotation kernel parameters (`fbcon=rotate:1` and
`video=DSI-1:panel_orientation=right_side_up`), the `vbgr` subpixel order that
a rotated screen needs, the Iris Xe media drivers, the IIO accelerometer behind
automatic rotation, the NVMe and Thunderbolt initrd modules, and the
`snd-intel-dspcfg dsp_driver=1` quirk without which the 1195G7's audio is
silent. `hardware.nix` adds only what that module leaves out: microcode,
Bluetooth, thermald, the fingerprint reader and power-profiles-daemon.

## Installation

Installation **erases the whole of the target disk**. Confirm the device node
first — `disko.nix` asserts `/dev/nvme0n1`, which is where the Pocket 3's M.2
drive normally appears, but disko will not ask twice:

```bash
lsblk -o NAME,SIZE,MODEL
```

The flake reads the committed tree rather than the working copy, so the new
files must be staged and committed before deploying. Then, from a machine that
can reach Chimera booted into a NixOS installer or any SSH-reachable Linux:

```bash
nix-everywhere bootstrap --target-host root@<chimera-address> --flake .#chimera
```

The installer will prompt for the LUKS passphrase that `disko.nix` sets on the
root container. Choose it carefully: it is the only thing standing between a
mislaid eight-inch laptop and the API keys that `homes/jrt` writes into the
store.

After installation, set the account password — none is declared in the flake,
deliberately, so that no hash reaches Git or the Nix store:

```bash
ssh jrt@<chimera-address>
passwd
```

## The two sessions

`tuigreet` presents both; F2 opens the menu, and the choice is remembered.

**Plasma (default).** Plasma's Wayland session handles the rotation, the
fractional scaling and the touchscreen from System Settings without being told,
which is what one wants on an eight-inch convertible and on first boot.

**Hyprland (Classic).** The waybar, rofi and dunst stack, with rotation coming
from the monitor line in `homes/jrt/variables.nix`. Hyprland's transform is `1`
for ninety degrees and `3` for two hundred and seventy; the correct value for
this panel should be confirmed on the hardware rather than trusted from a
configuration file. Try it live before editing anything:

```bash
hyprctl keyword monitor DSI-1,1200x1920@60,0x0,1.5,transform,3
```

If `3` is right, change the digit in `homes/jrt/variables.nix` and re-apply the
home configuration.

Caelestia and Omnixy are absent by design: both are tuned to Bebop's monitor
geometry, and porting them to a rotated portrait panel would be a second piece
of work for no gain here.

## The home profile

The system configuration and the home configuration are applied separately:

```bash
./do host apply chimera
./do home apply jrt
```

Claude Code authenticates through Max OAuth rather than an API key, so its first
login needs a browser and therefore a desktop session:

```bash
claude login
codex login
```

## Headscale enrolment

As with the other hosts, the pre-auth key never enters the flake. Install it
root-owned from the unlocked `home-lab` checkout, then confirm enrolment:

```bash
./scripts/deploy-headscale-preauth chimera   # from the home-lab checkout
ssh chimera 'sudo install -D -o root -g root -m 0600 /dev/stdin /etc/headscale/preauth'
tailscale status
tailscale debug prefs | jq -e '.ControlURL == "https://hs.glottologist.co.uk"'
```

The enrolment unit retries on failure, so the key may be installed after the
first boot without a rebuild.

## NymVPN

NymVPN is not in nixpkgs. `shared/network/nym-vpn-core.nix` packages upstream's
prebuilt Linux release, and `hosts/common/nym-vpn.nix` runs `nym-vpnd` as a
root systemd service, since the daemon creates the tunnel interface, rewrites
routing and programmes nftables directly over netlink.

```bash
systemctl status nym-vpnd
nym-vpnc --version
```

The account credential is stored on the machine, not in the flake:

```bash
nym-vpnc account set          # login with the recovery mnemonic
nym-vpnc account summary
nym-vpnc connect
nym-vpnc status
```

The daemon listens on `/var/run/nym-vpn.sock`. If `nym-vpnc` reports a
permission error reaching it, run the client under `sudo`; upstream ships no
group-based access policy for that socket, so none is asserted here.

Note that `nym` — the mixnet tooling in `networking.nix` — is a different thing
from NymVPN. It provides a SOCKS5 proxy for individual applications, where
`nym-vpnd` provides the device-wide tunnel. Both are installed, on purpose.

## Writing

The prose toolchain is `shared/writing`: Obsidian, Logseq, Zettlr, Apostrophe,
FocusWriter, Ghostwriter, novelWriter and Manuskript for the writing itself;
Vale, proselint, write-good, LanguageTool and Harper for reading it back;
`en_GB-ise` dictionaries so that British spelling is the default rather than a
correction; LibreOffice and Pandoc for everything other people send; and
Calibre, Foliate, Sioyek and Xournal++ for reading and annotating.

`shared/documentation` sits alongside it with the technical side — mdBook, the
LaTeX editors, the PDF tooling — and the LaTeX, Typst and Markdown language
modules come with it.

## Bumping NymVPN

Upstream publishes a `.sha256sum` asset beside each release tarball. To move to
a new version, change `version` in `shared/network/nym-vpn-core.nix` and take
the new hash:

```bash
nix store prefetch-file --json \
  "https://github.com/nymtech/nym-vpn-client/releases/download/nym-vpn-v<version>/nym-vpn-core-v<version>_linux_x86_64.tar.gz" \
  | jq -r .hash
```
