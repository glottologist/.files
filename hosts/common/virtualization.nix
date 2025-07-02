{
  config,
  pkgs,
  ...
}: {
  programs.dconf = {
    enable = true;
  };

  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [pkgs.OVMFFull.fd];
      };
    };
    spiceUSBRedirection.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    dive # A tool for exploring each layer in a docker image
    podman # A program for managing pods, containers and container images
    podman-compose # An implementation of docker-compose with podman backend
    podman-desktop # A graphical tool for developing on containers and Kubernetes
    podman-tui # Podman Terminal UI
    spice # Complete open source solution for interaction with virtualized desktop devices
    spice-gtk
    spice-protocol
    virt-manager
    virt-viewer
    win-spice
    win-virtio
  ];

  services.spice-vdagentd.enable = true;
}
