{ config, pkgs, ... }:
{

  environment.systemPackages =  with pkgs; [
     cointop                # Terminal based crypto prices
     electrum               # A lightweight bitcoin wallet
     exodus                 # Top rated crypto wallet with Trezor integration and built-in exchange
     hidapi                 # Library for communicating with UBS and Bluetooth HID devices
     ledger-live-desktop    # Ledger Live Desktop Client
     ledger-udev-rules      # Udev rules for interacting with LEdger Hardware wallets
     ledger-web             # A Web front end to the ledger CLI tool
     wasabiwallet           # Privacy focused local Bitcoin wallet
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
