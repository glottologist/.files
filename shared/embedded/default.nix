# Microcontroller development, currently centred on the RP2040/RP2350 boards of
# the Raspberry Pi Pico starter kit. Both routes the kit tutorials take are
# covered: MicroPython through Thonny and the on-device REPL, and C/C++ through
# the Pico SDK and the arm-none-eabi toolchain.
#
# Device access is a host concern rather than a package one, so the udev rules
# and the groups that make a freshly plugged Pico usable live in
# hosts/common/embedded.nix.
{
  lib,
  pkgs,
  ...
}: let
  # The SDK's default build omits its submodules, which costs us TinyUSB — the
  # component behind every "printf over USB" example in the tutorials. We take
  # the submodule-bearing variant and point PICO_SDK_PATH at it so that a plain
  # `cmake ..` in a tutorial project finds a complete SDK.
  picoSdk = pkgs.pico-sdk.override {withSubmodules = true;};

  # Raspberry Pi's fork carries the rp2040 and rp2350 targets that upstream
  # OpenOCD lacks, but it installs the same `bin/openocd` and the same udev
  # rules as the upstream build that shared/pentesting brings in, and buildEnv
  # refuses to merge two packages that claim one path. Exposing the fork under a
  # name of its own keeps both on PATH; it finds its own scripts through a
  # compiled-in prefix, so the rename costs nothing. The host-side udev rules it
  # also carries are installed by hosts/common/embedded.nix, where udev can
  # actually read them.
  openocdPico = pkgs.runCommand "openocd-rp2040-renamed" {} ''
    mkdir -p "$out/bin"
    ln -s ${pkgs.openocd-rp2040}/bin/openocd "$out/bin/openocd-rp2040"
  '';
in {
  home.packages = with pkgs; [
    thonny # The IDE the kit's MicroPython tutorials are written against
    micropython # Host build of the interpreter, for trying a script without the board
    mpremote # Official MicroPython remote control: REPL, file copy, mount, run
    adafruit-ampy # Older file-transfer tool that the kit tutorials still reference
    picotool # Inspect, load and reboot a board in BOOTSEL mode
    picoSdk # Headers, libraries and CMake machinery for the C/C++ examples
    # The toolchain bundles arm-none-eabi-gdb, whose share/gdb/syscalls files
    # collide with those of the native gdb that shared/languages/odin and
    # shared/pentesting install. Lowering the priority hands the shared paths to
    # the native gdb; the arm-none-eabi binaries have names of their own and are
    # untouched.
    (lib.lowPrio gcc-arm-embedded) # arm-none-eabi gcc, binutils and gdb for the Cortex-M target
    openocdPico # Raspberry Pi's OpenOCD fork, for SWD debugging over a probe
  ];

  # The SDK's CMake entry point is found through this variable, and `cmake` and
  # `gnumake` themselves arrive with shared/languages/cplusplus and
  # shared/languages/c, so they are deliberately not repeated here.
  home.sessionVariables = {
    PICO_SDK_PATH = "${picoSdk}/lib/pico-sdk";
  };
}
