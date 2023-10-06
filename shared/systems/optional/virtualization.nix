{
  config,
  pkgs,
  ...
}: {
  programs.dconf = {
    enable = true;
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [pkgs.OVMFFull.fd];
      };
    };
    spiceUSBRedirection.enable = true;
    #docker.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    qemu_kvm # A generic and open source machine emulator and virtualizer
    dive # A tool for exploring each layer in a docker image
    docker-ls # Tools for browsing and manipulating docker registries
    docker-compose # Multi-container orchestration for Docker
    podman # A program for managing pods, containers and container images
    podman-tui # Podman Terminal UI
    podman-desktop # A graphical tool for developing on containers and Kubernetes
    podman-compose # An implementation of docker-compose with podman backend
    spice # Complete open source solution for interaction with virtualized desktop devices
    virt-manager
    virt-viewer
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
  ];

  services.spice-vdagentd.enable = true;
}
