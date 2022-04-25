{ config, lib, pkgs, modulesPath, ... }:
{

  imports =
    [
      #(modulesPath + "/installer/scan/not-detected.nix")
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware = {
     cpu.intel.updateMicrocode =  lib.mkDefault config.hardware.enableRedistributableFirmware;
      video.hidpi.enable = lib.mkDefault true;
      opengl = {
        enable = true;
        driSupport32Bit = true;
        extraPackages32 = with pkgs.pkgsi686Linux; [
          libva
        ];
        extraPackages = with pkgs; [
         intel-media-driver
         libvdpau-va-gl
         vaapiIntel
         vaapiVdpau
        ];
      };
      pulseaudio = {
        enable = true;
        support32Bit = true;
        package = pkgs.pulseaudioFull;
        zeroconf.discovery.enable = true;
        systemWide = true;
      };
      bluetooth = {
        enable = true;
      };
    };
}
