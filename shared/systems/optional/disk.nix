{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
       diskonaut   # Terminal disk space navigator
       etcher      # Flash OS images to SD cards and USB drives, safely and easily
       #exfat       # Exfat utils
       exfatprogs  # Exfat utils that work wih gparted
       fuse3       # Fuse filesystems
       gparted     # Graphical disk partitioning tool
       lethe       # Tool to wipe drives in a secure way
       ntfs3g      # FUSE-based NTFS driver with full write support
       parted      # Create, destroy, resize, check, and copy partitions
       tree        # Command to produce a depth indented directory listing
       unzip       # Compression utils
       woeusb      # Create bootable USB diskc from Windows ISO images
       woeusb-ng   # Create bootable USB diskc from Windows ISO images
       zip         # Compression utils

   ];
}
