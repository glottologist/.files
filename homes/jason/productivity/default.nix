{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
  ];

  home.packages = with pkgs; [
    dstask            # Command line todo list with super-reliable git sync
    rainbowstream     # Streaming command-line twitter client
    adobe-reader      # PDF Reader
  ];

  programs = {
  };

  services = {
  };
}
