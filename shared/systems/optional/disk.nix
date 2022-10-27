{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
       diskonaut   # Terminal disk space navigator
       etcher      # Flash OS images to SD cards and USB drives, safely and easily
       parted      # Create, destroy, resize, check, and copy partitions
       gparted     # Graphical disk partitioning tool
       lethe       # Tool to wipe drives in a secure way
       ntfs3g      # FUSE-based NTFS driver with full write support
       tree        # Command to produce a depth indented directory listing
       woeusb      # Create bootable USB diskc from Windows ISO images

   ];
}
