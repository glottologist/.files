{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
  ];

  home.packages = with pkgs; [
    dstask            # Command line todo list with super-reliable git sync
  ];

  programs = {
  };

  services = {
  };
}
