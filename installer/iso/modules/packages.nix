{pkgs, lib, config, ...}:
{
  environment.systemPackages = with pkgs; [
    wget
    curl
    bind
    killall
    dmidecode
    neofetch
    htop
    bat
    unzip
    file
    zip
    p7zip
    strace
    ltrace
    git
    git-crypt
    hwdata
    acpi
    pciutils
    bintools
    btrfs-progs
    smartmontools
    xar
    ripgrep
    nvme-cli
    lm_sensors
    python3
    nwipe
    vim
    gnufdisk
    gcc
    gnumake
    bvi
    cryptsetup
    parted
    ntfsprogs
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" "usb_storage" ];

}
