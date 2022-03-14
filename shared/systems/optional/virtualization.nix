{ config, pkgs, ... }:

{
  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };


  environment.systemPackages = with pkgs; [
     qemu_kvm
   ];

}
