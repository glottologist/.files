{ config, pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
     electrum  # A lightweight bitcoin wallet
     exodus  # Top rated crypto wallet with Trezor integration and built-in exchange
     hidapi  # Library for communicating with UBS and Bluetooth HID devices
     ledger-live-desktop
     ledger-udev-rules
     ledger-web
     trezord
     wasabiwallet  # Privacy focused local Bitcoin wallet
   ];

  services = {
    udev = {
      packages = with pkgs; [
        yubikey-personalization
        ledger-udev-rules
        trezor-udev-rules
      ];
    };
    pcscd = {
      enable = true;
    };
  };

}
