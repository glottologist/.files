# What nixos-hardware's gpd/pocket-3 module does not already cover.
#
# That module is doing the heavy lifting: the panel rotation, the subpixel
# order for a rotated screen, the Iris Xe media drivers, the IIO accelerometer
# behind automatic rotation, the DSP quirk the 1195G7's audio needs, and the
# NVMe and Thunderbolt initrd modules. This file adds only what a portable
# machine wants on top of it — firmware, Bluetooth, and the fingerprint reader
# and thermal management that a laptop profile does not assume.
{ config, lib, ... }:
{
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = true;
    graphics.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  # Tiger Lake's thermal envelope in a chassis this small is genuinely tight,
  # and thermald is Intel's own answer to it. Without it the Pocket 3 throttles
  # hard rather than gracefully.
  services.thermald.enable = true;

  # The Pocket 3 carries a fingerprint reader; enrol with `fprintd-enroll`.
  services.fprintd.enable = true;

  # nixos-hardware's laptop profile enables TLP unless power-profiles-daemon is
  # on. We take power-profiles-daemon instead, because Plasma's battery applet
  # drives it directly and the user can then change profile from the desktop.
  services.power-profiles-daemon.enable = true;
}
