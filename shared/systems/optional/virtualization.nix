{ config, pkgs, ... }:

{
  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };


  environment.systemPackages = with pkgs; [
    qemu_kvm            # A generic and open source machine emulator and virtualizer
    dive                # A tool for exploring each layer in a docker image
    docker-ls           # Tools for browsing and manipulating docker registries
    docker-compose      # Multi-container orchestration for Docker
    podman              # A program for managing pods, containers and container images
    podman-compose      # An implementation of docker-compose with podman backend
   ];

}
