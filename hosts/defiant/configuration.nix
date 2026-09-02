# Defiant — Hetzner Cloud CX22 (2 Intel vCPU, 3.7 GiB, 38.1 GiB, 65.109.6.50).
# Legacy BIOS boot. Agent host: Ennio, Syncthing to Bebop, Plasma over RDP on
# the tailnet.
#
# This configuration replaces a Debian 12 image that ran a Twingate connector;
# its loss was authorised when the host was reinstalled.
#
# hosts/common/ai.nix is deliberately NOT imported: it enables Ollama and
# pulls a 16.8 GB model, which belongs on Bebop's APU, not on a 3.7 GiB guest.
{ ... }:
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./networking.nix
    ./users.nix
    ./services.nix
    ../common/hetzner-disk.nix
    ../common/nix.nix
    ../common/tailscale.nix
    ../common/plasma-desktop.nix
    ../common/xrdp-tailnet.nix
    ../common/ennio-node.nix
    ../common/syncthing-bebop.nix
  ];

  system.stateVersion = "26.05";
}
