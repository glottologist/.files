# The Pocket 3 boots UEFI, so the loader is systemd-boot.
#
# There is no LUKS passphrase in this boot path: the machine was switched in
# place over a stock install and kept its plaintext layout, which
# filesystem.nix declares and disko.nix does not describe.
#
# Almost nothing about the display or the storage needs saying here:
# nixos-hardware's gpd/pocket-3 module already loads i915 early and already
# sets the panel rotation kernel parameters. What remains is the generation
# limit, the quiet boot, the controllers the initrd needs to reach the root,
# and the resume device.
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
      # The root is a plain ext4 partition on the internal NVMe, so the initrd
      # needs only the controllers that reach it. Thunderbolt and the USB
      # modules are here because the Pocket 3 boots from external media often
      # enough to want them present.
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      systemd.enable = true;
    };

    # Hibernation resumes from the swap partition that the in-place install
    # inherited. At 8.8G against 15.5 GiB of RAM it is smaller than a full
    # memory image, so hibernation succeeds only while the kernel can shrink
    # the image to fit — which its default target of two fifths of RAM
    # ordinarily does, but a loaded machine will not.
    resumeDevice = "/dev/disk/by-uuid/f069ed7d-1c0a-46fe-8faf-e3c7f37961f7";

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
