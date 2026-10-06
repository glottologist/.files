# Chimera — GPD Pocket 3 for writing, agents, remote access and security testing.
#
# hosts/common/ai.nix is deliberately not imported. It runs Ollama and a
# llama.cpp server over models measured in tens of gigabytes, which belong on
# Bebop's APU and its 93 GiB of shared memory, not on a machine one carries.
# The agent CLIs in homes/jrt reach hosted models and Bebop's endpoints
# instead.
{ ... }:
{
  imports = [
    ./boot.nix
    ./filesystem.nix
    ./fonts.nix
    ./hardware.nix
    ./networking.nix
    ./services.nix
    ./users.nix
    ./xdg.nix
    ../common/default_programs.nix
    ../common/harmonia-substituter.nix
    ../common/nix.nix
    ../common/nym-vpn.nix
    ../common/stylix.nix
    ../common/tailscale.nix
    ../common/veracrypt.nix
    ../../shared/osint/default.nix
    ../../shared/pentesting/default.nix
  ];

  system.stateVersion = "26.05";
}
