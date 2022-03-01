#!/usr/bin/sh

PARTITIONTYPE=$1
PARTITIONNAME=$2
SUB_PARTITION_NIXOS='1'
SUB_PARTITION_SWAP='2'
SUB_PARTITION_BOOT='3'


override_sub_partition_numbers() {
 if [[ $PARTITIONTYPE == *"nvme"* ]]; then
   echo "Drive is an NVME drive, setting correct subpartitions"
   SUB_PARTITION_NIXOS='p1'
   SUB_PARTITION_SWAP='p2'
   SUB_PARTITION_BOOT='p3'
 fi
}

partition_uefi() {
  # Create partition table
  sudo parted "$PARTITIONNAME" -- mklabel gpt

  # Add root partition
  sudo parted "$PARTITIONNAME" -- mkpart primary 512MiB -8GiB

  # Add swap partition
  sudo parted "$PARTITIONNAME" -- mkpart primary linux-swap -8GiB 100%

  # Create boot partition
  sudo parted "$PARTITIONNAME" -- mkpart ESP fat32 1MiB 512MiB
}

partition_mbr() {

  # Create partition table
  sudo parted "$PARTITIONNAME" -- mklabel msdos

  # Add root partition
  sudo parted "$PARTITIONNAME" -- mkpart primary 1MiB -8GiB

  # Add swap partition
  sudo parted "$PARTITIONNAME" -- mkpart primary linux-swap -8GiB 100%

}

format_common() {

  # Format nixos partition
  sudo mkfs.ext4 -L nixos "${PARTITIONNAME}${SUB_PARTITION_NIXOS}"

  # Make swap
  sudo mkswap -L swap "${PARTITIONNAME}${SUB_PARTITION_SWAP}"

}

format_uefi() {
  # Format FAT partition
  sudo mkfs.fat -F 32 -n boot "${PARTITIONNAME}${SUB_PARTITION_BOOT}"

}

mount_common() {
# Mount nixos
sudo mount /dev/disk/by-label/nixos /mnt
}

mount_uefi() {
# Mount boot
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
}

enable_swap() {
sudo swapon "${PARTITIONNAME}${SUB_PARTITION_SWAP}"
}

print_help() {
 echo "======================================================================"
 echo "sh partition.sh <partitiontype> <partitionname>"
 echo "=> where:"
 echo "=> partitiontype = Is one of 'uefi' or 'msdos'"
 echo "=> partitionname = Is the name od the partition including '/dev', i.e. '/dev/sda','/dev/sdb' or '/dev/nvme0n1'."
 echo "======================================================================"

}

check_partition_name_arg() {
if [ -z "$PARTITIONNAME" ]
then
      echo "INCORRECT USAGE:  No partition name was provided. "
      print_help
      exit 1;
fi

}

check_partition_type_arg() {
if [ -z "$PARTITIONTYPE" ]
then
      echo "INCORRECT USAGE:  No partition type was provided. "
      print_help
      exit 1;
fi
}


uefi_system() {
  partition_uefi
  format_common
  format_uefi
  mount_common
  mount_uefi
}

msdos_system() {
  partition_mbr
  format_common
  mount_common
}

main() {
  check_partition_type_arg
  check_partition_name_arg
  override_sub_partition_numbers

  case $PARTITIONTYPE in
  "uefi")
     uefi_system
   ;;
  "msdos")
     msdos_system
   ;;
  *)
    print_help
    ;;
  esac
}


main




