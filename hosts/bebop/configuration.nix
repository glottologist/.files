{ ... }:
{
  imports = [
    ./boot.nix
    ./filesystem.nix
    ./fonts.nix
    ./hardware.nix
    ./location.nix
    ./networking.nix
    ./nix.nix
    ./security.nix
    ./services.nix
    ./storage.nix
    ./users.nix
    ./xdg.nix
    ../common/ai.nix
    ../common/blockchain.nix
    ../common/comics.nix
    ../common/communication.nix
    ../common/default_programs.nix
    ../common/development.nix
    ../common/devices.nix
    ../common/disk.nix
    ../common/keyboards.nix
    ../common/nix.nix
    ../common/harmonia-substituter.nix
    ../common/stylix.nix
    ../common/tailscale.nix
    ../common/veracrypt.nix
    ../common/virtualization.nix
    # Same modules homes/glottologist imports. Dual-purpose: on NixOS they
    # land in environment.systemPackages (and dumpcap via programs.wireshark).
    ../../shared/osint/default.nix
    ../../shared/pentesting/default.nix
  ];
  system = {
    stateVersion = "26.05";
  };
}
