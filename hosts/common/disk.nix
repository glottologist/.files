{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
   exfatprogs # Exfat utils that work wih gparted
    fuse3 # Fuse filesystems
    gparted # Graphical disk partitioning tool
    lethe # Tool to wipe drives in a secure way
    ntfs3g # FUSE-based NTFS driver with full write support
    parted # Create, destroy, resize, check, and copy partitions
    tree # Command to produce a depth indented directory listing
    woeusb # Create bootable USB diskc from Windows ISO images
    woeusb-ng # Create bootable USB diskc from Windows ISO images
  ];
}
