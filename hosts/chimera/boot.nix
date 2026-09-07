# The Pocket 3 boots UEFI, so the loader is systemd-boot.
#
# Almost nothing about the display or the storage needs saying here:
# nixos-hardware's gpd/pocket-3 module already loads i915 early — which is what
# puts the LUKS passphrase prompt on the screen rather than into the dark — and
# already sets the panel rotation kernel parameters. What remains is the
# generation limit, the quiet boot, and the resume device that the encrypted
# swap in disko.nix requires.
{ ... }:
{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        # The ESP is 1G and each generation costs roughly 45M of kernel and
        # initrd, so ten is comfortable rather than tight.
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    initrd = {
      verbose = false;
      # The root sits on LVM inside the LUKS container, so the initrd needs the
      # device-mapper modules to find it after the passphrase is accepted.
      availableKernelModules = [ "dm-snapshot" ];
      systemd.enable = true;
    };

    # Hibernation resumes from the swap logical volume, which only exists once
    # cryptroot is open; naming it by its device-mapper path is what lets the
    # resume happen inside the initrd rather than after the root is mounted.
    resumeDevice = "/dev/chimera/swap";

    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };
}
