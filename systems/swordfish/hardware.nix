{ config, lib, pkgs, modulesPath, ... }:

{

  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  hardware = {
      video.hidpi.enable = lib.mkDefault true;
      raspberry-pi."4".fkms-3d.enable = true;
    };
}
