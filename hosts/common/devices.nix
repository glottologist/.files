{
  config,
  pkgs,
  ...
}: {
  environment = {
    systemPackages = with pkgs; [
    binutils
      hidapi # Library for communicating with USB and Bluetooth HID devices
      libusb1 # cross-platform user-mode USB device library
      hardinfo2 #  GUI hardward information
      lshw # Command line hardward information
    ];
  };
}
