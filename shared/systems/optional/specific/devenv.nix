{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (import (fetchTarball "https://install.devenv.sh/latest")).default
  ];

}

