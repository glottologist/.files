# Host-side device access for the microcontroller toolchain in
# shared/embedded/default.nix. Packages alone cannot make a freshly plugged
# Raspberry Pi Pico usable: the BOOTSEL mass-storage interface and the USB
# serial REPL both need udev's help before an unprivileged session may touch
# them.
{pkgs, ...}: {
  services.udev = {
    # picotool ships rules granting uaccess to the RP2040 and RP2350 BOOTSEL
    # interfaces, and OpenOCD ships rules for the debug probes. The probe-rs
    # rules that cover the Debug Probe itself are already imported through
    # hosts/common/keyboards.nix.
    packages = with pkgs; [
      picotool
      openocd-rp2040
    ];

    # ModemManager probes every CDC-ACM port that appears, and while it holds
    # the port Thonny or mpremote cannot open the REPL; the symptom is a
    # connection that fails for a few seconds after each reset and then
    # succeeds. The tag must be set on the USB device rather than the tty, as
    # ModemManager's filter reads it from the parent.
    extraRules = ''
      # Raspberry Pi Pico (RP2040/RP2350) — keep ModemManager off the REPL
      ACTION!="add|change|move", GOTO="mm_pico_end"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ENV{ID_MM_DEVICE_IGNORE}="1"
      LABEL="mm_pico_end"
    '';
  };
}
