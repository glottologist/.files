# Chimera — GPD Pocket 3, an eight-inch convertible for writing, agents and
# reaching the other machines.
#
# The import list is the whole design in miniature. What is present serves one
# of the four capabilities the machine exists for; what is absent — the
# blockchain, comics, trading, virtualisation and device modules that Bebop
# carries — does not.
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
  ];

  system.stateVersion = "26.05";
}
