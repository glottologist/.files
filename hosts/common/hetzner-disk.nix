# Hybrid GPT for Hetzner Cloud guests: the EF02 partition lets a legacy-BIOS
# host boot, the ESP lets a UEFI host boot, and one layout therefore serves
# both Reliant (UEFI) and Defiant (BIOS). Partition order is disko's default
# by priority: EF02 first, the 100% root last.
{
  # These guests are 38–76 GiB. A home-manager apply that vendors a Rust
  # crate graph will fill the disk and fail fetchurl with a one-line log
  # unless Nix GCs mid-build. 4 GiB is enough headroom for one crate
  # fetch; 10 GiB is a single GC target, not a reservation.
  nix.settings = {
    min-free = 4 * 1024 * 1024 * 1024;
    max-free = 10 * 1024 * 1024 * 1024;
  };

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02";
        };
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "defaults" ];
          };
        };
        swap = {
          size = "4G";
          content = {
            type = "swap";
            resumeDevice = true;
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
