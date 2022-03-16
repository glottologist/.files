{ config, lib, pkgs, modulesPath, ... }:

{

  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware = {
      video.hidpi.enable = lib.mkDefault true;
      opengl = {
        enable = true;
        extraPackages = with pkgs; [
         intel-media-driver
         vaapiIntel
         vaapiVdpau
         libvdpau-va-gl

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
