{ config, lib, pkgs, modulesPath, ... }:
{

  imports =
    [
      #(modulesPath + "/installer/scan/not-detected.nix")
    ];

    powerManagement = {
      enable = true;
      #cpuFreqGovernor = null;
      cpuFreqGovernor = lib.mkDefault "powersave";
   };
  hardware = {
      cpu.intel.updateMicrocode =  lib.mkDefault config.hardware.enableRedistributableFirmware;
      #video.hidpi.enable = lib.mkDefault true;
      opengl = {
        enable = true;
        extraPackages = with pkgs; [
         intel-media-driver
         libvdpau-va-gl
         vaapiIntel
        ];
      };
      pulseaudio = {
        enable = true;
        support32Bit = true;
        package = pkgs.pulseaudioFull;
      };
      bluetooth = {
        enable = true;
      };
      blueman.enable = true;
    };
}
