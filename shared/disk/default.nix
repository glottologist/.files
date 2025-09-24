{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    dua # Tool to conveniently learn about the disk usage of directories
    dysk #Disk space until
    exfatprogs # Exfat utils that work wih gparted
    fuse3 # Fuse filesystems
    gdu # Disk usage analyzer with console interface
    gparted # Graphical disk partitioning tool
    lethe # Tool to wipe drives in a secure way
    ntfs3g # FUSE-based NTFS driver with full write support
    parted # Create, destroy, resize, check, and copy partitions
    tree # Command to produce a depth indented directory listing
    unzip # Compression utils
    woeusb # Create bootable USB diskc from Windows ISO images
    zip # Compression utils
  ];
}
