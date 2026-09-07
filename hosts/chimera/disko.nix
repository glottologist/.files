# Chimera's disk: an encrypted root on the Pocket 3's internal NVMe.
#
# Encryption is not optional on a machine this portable. The store holds the
# OpenAI and Grok keys that homes/jrt exports, and a laptop small enough to
# lose is a laptop that will eventually be lost; LUKS is what keeps that from
# being a key compromise as well as a hardware one.
#
# Swap lives inside the encrypted container rather than beside it, so that
# hibernation images and swapped-out secrets are covered by the same key. It is
# sized at 16G against the Pocket 3's 16 GiB of RAM, which is what hibernation
# needs.
#
# The device node is asserted, not detected. Confirm it with `lsblk` before
# installing: disko erases whatever it is pointed at, without asking twice.
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["umask=0077"];
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
            content = {
              type = "lvm_pv";
              vg = "chimera";
            };
          };
        };
      };
    };
  };

  disko.devices.lvm_vg.chimera = {
    type = "lvm_vg";
    lvs = {
      swap = {
        size = "16G";
        content = {
          type = "swap";
          resumeDevice = true;
        };
      };
      root = {
        size = "100%FREE";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/";
        };
      };
    };
  };
}
