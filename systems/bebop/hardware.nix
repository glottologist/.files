{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    #(modulesPath + "/installer/scan/not-detected.nix")
  ];

  powerManagement = {
    enable = true;
    #cpuFreqGovernor = null;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        libvdpau-va-gl
        vaapiIntel
      ];
    };
    pulseaudio = {
      enable = false;
      package = pkgs.pulseaudioFull;
    };
    bluetooth = {
      enable = true;
    };
  };
}
