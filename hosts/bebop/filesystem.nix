{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c0586a48-c5c7-4f82-a559-5839d2631d8f";
      fsType = "ext4";
    };


  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3A90-56B9";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  # zram alone cannot relieve memory pressure: its compressed pages are held in
  # RAM, so a full zram device shrinks the working set instead of freeing it. On
  # 2026-09-28 all 46 GiB of zram filled, 21 GiB of RAM was tied up holding the
  # compressed pages, and the machine spent 39 minutes in an OOM loop it could
  # not escape. A disk-backed swapfile gives reclaim a real destination, and
  # restores the I/O stall that makes PSI pressure signals meaningful again.
  # See agents/2026-09-28-001-research-system-hang-oom-investigation.md.
  #
  # The swapfile lives on the LUKS-encrypted root, so its contents are encrypted
  # at rest. NixOS creates and formats it on activation; no manual setup needed.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32768; # MiB
      priority = 10; # below zram, so hot pages compress before they reach disk
    }
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
    priority = 100;
  };

  # Swap changes where reclaim goes; this bounds how much the interactive
  # session can demand in the first place. On 2026-09-28 three concurrent
  # claude processes reached 109 GiB between them with nothing to stop them.
  # MemoryHigh throttles rather than kills: crossing the line forces aggressive
  # reclaim and the session slows down visibly, instead of consuming the
  # machine silently until the kernel OOM killer flails. It lives here beside
  # swapDevices and zramSwap because the three are one memory-pressure policy
  # and should be read, and changed, together.
  #
  # The percentage is relative to installed physical memory, so 90% of 93.5 GiB
  # is roughly 84 GiB, leaving headroom for system.slice (ollama in particular)
  # and the kernel. The accounting includes page cache, which is reclaimed
  # first and harmlessly, so ordinary file-heavy work will not be throttled.
  #
  # user.slice already exists as a systemd unit, so NixOS emits this as a
  # drop-in rather than replacing it.
  #
  # ManagedOOMSwap arms the last line of defence. systemd-oomd was running
  # throughout the 2026-09-28 incident and killed nothing, because monitoring
  # is opt-in per slice and every slice was left at the "auto" default, so the
  # 90%-swap trigger never armed even at 100% swap. enableUserSlices below
  # covers the pressure trigger; swap monitoring has no NixOS option and has to
  # be set here. Between them, oomd kills the single offending scope (each
  # claude ran in its own tmux-spawn-*.scope) rather than leaving the kernel to
  # work through eighty Brave renderers first.
  systemd.slices."user".sliceConfig = {
    MemoryHigh = "90%";
    ManagedOOMSwap = "kill";
  };

  # Pressure monitoring on user.slice and on the user's own slice hierarchy,
  # which is what makes a kill land on one application scope instead of the
  # whole session. This only became useful once a disk-backed swapfile existed:
  # zram reclaim is a compression pass against RAM with no I/O stall, so PSI
  # pressure stays low and the trigger never fires on a zram-only system.
  systemd.oomd.enableUserSlices = true;
}
