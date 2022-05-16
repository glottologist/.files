{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    waydroid       # Waydroid is a container-based approach to boot a full Android system on a regular GNU/Linux system like Ubuntu
  ];

}

