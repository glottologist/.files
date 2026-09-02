# Reliant — Hetzner Cloud CPX22 (2 AMD vCPU, 3.7 GiB, 76.3 GiB, 178.104.185.209).
# UEFI boot. Agent host: Ennio, Syncthing to Bebop, Plasma over RDP on the tailnet.
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
    ./harmonia.nix
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
